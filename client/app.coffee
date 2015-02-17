'use strict'

app = angular.module 'loopbackSatellizer', [
  'ng'
  'lbServices'
  'ui.router'
  'satellizer'
  'app.templates'
]

app.config (
  $locationProvider
  $stateProvider
  $urlRouterProvider
  $authProvider
) ->

  $locationProvider.html5Mode
    enabled: true,
    requireBase: false

  $stateProvider
  .state 'homepage',
    url: '/'
    controller: 'HomepageCtrl'
    templateUrl: 'homepage.html'

  $urlRouterProvider.otherwise '/'

  $authProvider.facebook clientId:'835214883204154'
