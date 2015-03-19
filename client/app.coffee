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
  .state 'profile',
    url: '/profile'
    controller: 'ProfileCtrl'
    templateUrl: 'profile.html'

  $urlRouterProvider.otherwise '/'

  $authProvider.facebook
    clientId:'835214883204154'
    url: 'api/Users/auth/facebook'

  $authProvider.google
    clientId:'225218451685-st1fof92k2md25o96tpdem7lkfe4nkbq.apps.googleusercontent.com'
    url: 'api/Users/auth/google'
