app.controller 'HomepageCtrl', ($scope, $auth, Account, $state) ->
  $scope.authenticate = (provider) ->
    $auth.authenticate provider
    .then ->
      $state.go('profile')
