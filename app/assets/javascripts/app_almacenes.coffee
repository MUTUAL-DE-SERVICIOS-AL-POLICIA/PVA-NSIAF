angular.module('almacenes', ['ngRoute', 'templates'])

.config (["$routeProvider", ($routeProvider) ->
  $routeProvider
    .when('/', {
      controller: 'EntradasController',
      templateUrl: 'almacenes/_index.html'
    })
    .otherwise({
      redirectTo: '/'
    })
])

# Controladores
.controller('EntradasController', ['$scope', '$http', ($scope, $http) ->
  $scope.entradas = []

  $http.get('http://127.0.0.1:3000/api/nota_entradas').success((data) ->
    $scope.entradas = data.nota_entradas
  ).error (data, status) ->
    console.log status, data
])
