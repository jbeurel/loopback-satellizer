app.factory 'Account', (User) ->
  return {
    getProfile: ->
      return User.me()
  }
