app.controller 'HomepageCtrl', ($scope, $auth) ->
  $scope.authenticate = (provider) ->
    $auth.authenticate provider
