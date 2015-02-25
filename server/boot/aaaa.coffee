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
    sub: user._id
    iat: moment().unix()
    exp: moment().add(14, 'days').unix()
  jwt.encode payload, 'A hard to guess string'

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
        cb 500, accessToken.error.message
      accessToken = qs.parse(accessToken)
      # Step 2. Retrieve profile information about the current user.
      request.get {
        url: graphApiUrl
        qs: accessToken
        json: true
      }, (err, response, profile) ->
        if response.statusCode != 200
          cb 500, message: profile.error.message
        if req.headers.authorization
          User.findOne { facebook: profile.id }, (err, existingUser) ->
            if existingUser
              cb 409, message: 'There is already a Facebook account that belongs to you'
            token = req.headers.authorization.split(' ')[1]
            payload = jwt.decode(token, 'A hard to guess string')
            User.find payload.sub, (err, user) ->
              if !user
                cb 400, message: 'User not found'
              user.facebook = profile.id
              user.picture = user.picture or 'https://graph.facebook.com/' + profile.id + '/picture?type=large'
              user.displayName = user.displayName or profile.name
              User.create user, (err, createdUser) ->
                console.log 'create User'
                cb null, createToken(createdUser), createdUser
                return
              return
            return
        else
          # Step 3b. Create a new user account or return an existing one.
          User.findOne { facebook: profile.id }, (err, existingUser) ->
            if existingUser
              token = createToken(existingUser)
              cb null, token
            user =
              'facebook': profile.id
              'picture': 'https://graph.facebook.com/' + profile.id + '/picture?type=large'
              'email': profile.email
              'displayName': profile.name
            User.create user, (err, createdUser) ->
              console.log 'create User'
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

  User.me = (cb) ->
    # read authorization header
    #  https://github.com/sahat/satellizer/blob/master/examples/server/node/server.js#L86
    cb null, username: 'toto'
    return

  User.remoteMethod 'me',
    http:
      path: '/me'
      verb: 'get'
    returns:
      arg: 'user'
      type: 'object'
  return