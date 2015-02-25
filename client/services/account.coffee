app.factory 'Account', ($http) ->
  return {
    getProfile: ->
      return $http.get '/api/Users/me'
  }
