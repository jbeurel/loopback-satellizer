'use strict'

app = angular.module 'karmabmx', [
  'ng'
  'ngResource'
  'ui.router'
  'ui.bootstrap'
  'app.templates'
]

app.config (
  $locationProvider
  $stateProvider
  $urlRouterProvider
) ->

  $locationProvider.hashPrefix '!'

  $stateProvider
  .state 'homepage',
    url: '/'
    controller: 'HomepageCtrl'
    templateUrl: 'homepage.html'

  $urlRouterProvider.otherwise '/'
