request = require('request')
qs = require('querystring')
moment = require('moment')
jwt = require('jwt-simple')

###
 |--------------------------------------------------------------------------
 | Generate JSON Web Token
 |--------------------------------------------------------------------------
###

createToken = (user) ->

  payload =
    sub: user.id
    iat: moment().unix()
    exp: moment().add(14, 'days').unix()
  jwt.encode payload, 'A hard to guess string'

#  https://github.com/strongloop/loopback-component-passport/blob/master/lib/passport-configurator.js#L29

module.exports = (app) ->
  User = app.models.User

  User.facebookAuth = (clientId, code, redirectUri, req, cb) ->
    accessTokenUrl = 'https://graph.facebook.com/oauth/access_token'
    graphApiUrl = 'https://graph.facebook.com/me'
    params =
      code: code
      client_id: clientId
      client_secret: '42b9452b5fa3d27571f0b1635f243683'
      redirect_uri: redirectUri
    # Step 1. Exchange authorization code for access token.
    request.get {
      url: accessTokenUrl
      qs: params
      json: true
    }, (err, response, accessToken) ->
      if response.statusCode != 200
        cb status:500, message: accessToken.error.message
        return
      accessToken = qs.parse(accessToken)
      # Step 2. Retrieve profile information about the current user.
      request.get {
        url: graphApiUrl
        qs: accessToken
        json: true
      }, (err, response, profile) ->
        if response.statusCode != 200
          cb status:500, message: profile.error.message
          return
        if req.headers.authorization
          User.findOne {where: {facebook: profile.id }}, (err, existingUser) ->
            if existingUser
              cb status: 409, message: 'There is already a Facebook account that belongs to you'
              return
            token = req.headers.authorization.split(' ')[1]
            payload = jwt.decode(token, 'A hard to guess string')
            User.findById payload.sub, (err, user) ->
              if !user
                cb status: 400, message: 'User not found'
                return
              user.facebook = profile.id
              user.picture = user.picture or 'https://graph.facebook.com/' + profile.id + '/picture?type=large'
              user.displayName = user.displayName or profile.name
              user.save {}, (err, createdUser) ->
                cb null, createToken(createdUser), createdUser
                return
              return
            return
        else
          # Step 3b. Create a new user account or return an existing one.
          User.findOne {where: {facebook: profile.id}}, (err, existingUser) ->
            if existingUser
              token = createToken(existingUser)
              cb null, token
              return
            user =
              'facebook': profile.id
              'picture': 'https://graph.facebook.com/' + profile.id + '/picture?type=large'
              'email': profile.email
              'displayName': profile.name
            User.create user, (err, createdUser) ->
              cb null, createToken(createdUser), createdUser
              return
            return
        return
      return
    return

  User.remoteMethod 'facebookAuth',
    http:
      path: '/auth/facebook'
      verb: 'post'
    accepts: [
      arg: 'clientId', type: 'string'
    ,
      arg: 'code', type: 'string'
    ,
      arg: 'redirectUri', type: 'string'
    ,
      arg: 'req', type: 'object', http: source: 'req'
    ]
    returns: [
      arg: 'token', type: 'string'
    ,
      arg: 'user', type: 'object'
    ]

  User.googleAuth = (clientId, code, redirectUri, req, cb) ->
    accessTokenUrl = 'https://accounts.google.com/o/oauth2/token'
    peopleApiUrl = 'https://www.googleapis.com/plus/v1/people/me/openIdConnect'
    params =
      code: code
      client_id: clientId
      client_secret: 'hj3lYiQPXSMZSGvZusLBIzf3'
      redirect_uri: redirectUri
      grant_type: 'authorization_code'
    # Step 1. Exchange authorization code for access token.
    request.post accessTokenUrl, {
      json: true
      form: params
    }, (err, response, token) ->
      accessToken = token.access_token
      headers = Authorization: 'Bearer ' + accessToken
      # Step 2. Retrieve profile information about the current user.
      request.get {
        url: peopleApiUrl
        headers: headers
        json: true
      }, (err, response, profile) ->
        # Step 3a. Link user accounts.
        if req.headers.authorization
          User.findOne {where: {google: profile.sub}}, (err, existingUser) ->
            if existingUser
              cb status: 409, message: 'There is already a Google account that belongs to you'
              return
            token = req.headers.authorization.split(' ')[1]
            payload = jwt.decode(token, 'A hard to guess string')
            User.findById payload.sub, (err, user) ->
              if !user
                cb status: 400, message: 'User not found'
                return
              user.google = profile.sub
              user.picture = user.picture or profile.picture.replace('sz=50', 'sz=200')
              user.displayName = user.displayName or profile.name
              user.save {}, (err, createdUser) ->
                cb null, createToken(createdUser), createdUser
                return
              return
            return
        else
          # Step 3b. Create a new user account or return an existing one.
          User.findOne {where: {google: profile.sub}}, (err, existingUser) ->
            if existingUser
              token = createToken(existingUser)
              cb null, token
              return

            user =
             'google': profile.sub
             'picture': profile.picture.replace('sz=50', 'sz=200')
             'email': profile.email
             'displayName': profile.name
            User.create user, (err, createdUser) ->
              cb null, createToken(createdUser), createdUser
              return
            return
        return
      return

  User.remoteMethod 'googleAuth',
    http:
      path: '/auth/google'
      verb: 'post'
    accepts: [
      arg: 'clientId', type: 'string'
    ,
      arg: 'code', type: 'string'
    ,
      arg: 'redirectUri', type: 'string'
    ,
      arg: 'req', type: 'object', http: source: 'req'
    ]
    returns: [
      arg: 'token', type: 'string'
    ,
      arg: 'user', type: 'object'
    ]

  User.me = (req, cb) ->
    # read authorization header
    # -> Create middleware -> https://github.com/strongloop/loopback/blob/master/server/middleware/status.js
    #  https://github.com/sahat/satellizer/blob/master/examples/server/node/server.js#L86

    unless req.headers.authorization
      cb status: 401,  message: 'Please make sure your request has an Authorization header'
      return

    token = req.headers.authorization.split(' ')[1]
    payload = jwt.decode(token, 'A hard to guess string')

    if payload.exp <= moment().unix()
      cb status: 401, message: 'Token has expired'
      return

    User.findById payload.sub, (err, user) ->
      cb null, user
      return

  User.remoteMethod 'me',
    http:
      path: '/me'
      verb: 'get'
    accepts: [
      arg: 'req', type: 'object', http: source: 'req'
    ]
    returns:
      arg: 'user'
      type: 'object'
      root: true
  return
