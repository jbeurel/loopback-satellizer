app.controller 'ProfileCtrl', ($scope, $auth, Account) ->
  $scope.isAuthenticated = $auth.isAuthenticated()

  $scope.updateProfile = ->
    Account.getProfile().$promise.then (user) ->
      $scope.profile = user

  $scope.updateProfile()

  $scope.link = (provider) ->
    $auth.link provider
    .then ->
      $scope.updateProfile()

  $scope.unlink = (provider) ->
    $auth.unlink provider
    .then ->
      $scope.updateProfile()
