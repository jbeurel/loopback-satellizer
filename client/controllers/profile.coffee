app.controller 'ProfileCtrl', ($scope, $auth, Account) ->
  $scope.isAuthenticated = $auth.isAuthenticated()

  $scope.updateProfile = ->
    Account.getProfile().$promise.then (user) ->
      $scope.profile = user

  $scope.updateProfile()
