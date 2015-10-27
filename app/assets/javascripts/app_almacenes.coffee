almacenes = angular.module('moduloAlmacenes', ['ngRoute', 'templates'])

almacenes.config (["$routeProvider", ($routeProvider) ->
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
almacenes.controller('EntradasController', ['$scope', '$http', ($scope, $http) ->
  $scope.entradas = []
  host = "." # "http://127.0.0.1:3000"

  $http.get("#{host}/api/nota_entradas").success((data) ->
    $scope.entradas = data.nota_entradas
  ).error (data, status) ->
    console.log status, data

  $scope.anularNotaEntrada = (nota_entrada) ->
    url = "#{host}/api/nota_entradas/#{nota_entrada.id}/anular"
    datos =
      mensaje: 'Anulación por falta de pruebas'
      authenticity_token: $scope.authenticity_token
    if confirm('¿Está seguro de anular la Nota de Entrada?')
      $http.put(url, datos).success((data) ->
        nota_entrada.anulado = true
      ).error (data, status) ->
        console.log status, data
])
