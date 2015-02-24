app.controller 'HomepageCtrl', ($scope, $auth, Account) ->
  $scope.authenticate = (provider) ->
    $auth.authenticate provider

  $scope.isAuthenticated = $auth.isAuthenticated()

  $scope.getProfile = Account.getProfile