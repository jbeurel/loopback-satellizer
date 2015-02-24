app.factory 'Account', ($http) ->
  return {
    getProfile: ->
      console.log 'getProfile'
      return $http.get '/api/Users/me'
  }
