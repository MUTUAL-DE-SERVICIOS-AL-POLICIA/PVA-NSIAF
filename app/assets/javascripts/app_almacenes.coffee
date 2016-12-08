almacenes = angular.module('moduloAlmacenes', ['ngRoute', 'templates'])

almacenes.config (["$routeProvider", ($routeProvider) ->
  $routeProvider
    .when('/entradas', {
      controller: 'EntradasController',
      templateUrl: 'almacenes/_index.html'
    })
    .when('/salidas', {
      controller: 'SalidasController',
      templateUrl: 'almacenes/salidas.html'
    })
    .otherwise({
      redirectTo: '/entradas'
    })
])

# Controladores
almacenes.controller('EntradasController', ['$scope', '$http', ($scope, $http) ->
  $scope.entradas = []
  host = "." # "http://127.0.0.1:3000"

  $http.get("#{host}/api/nota_entradas").success((data) ->
    $scope.entradas = data
  ).error (data, status) ->
    console.log status, data

  $scope.anularNotaEntrada = (nota_entrada) ->
    url = "#{host}/api/nota_entradas/#{nota_entrada.id}/anular"
    datos =
      authenticity_token: $scope.authenticity_token
      nota_entrada:
        mensaje: 'Anulación por falta de pruebas'
    if confirm('¿Está seguro de anular la Nota de Entrada?')
      $http.put(url, datos).success((data) ->
        nota_entrada.anulado = true
      ).error (data, status) ->
        console.log status, data
])

almacenes.controller('SalidasController', ['$scope', '$http', ($scope, $http) ->
  $scope.solicitudes = []
  host = "." # "http://127.0.0.1:3000"

  $http.get("#{host}/api/solicitudes").success((data) ->
    $scope.solicitudes = data
  ).error (data, status) ->
    console.error status, data

  $scope.anularSolicitud = (solicitud) ->
    url = "#{host}/api/solicitudes/#{solicitud.id}/anular"
    datos =
      authenticity_token: $scope.authenticity_token
      solicitud:
        mensaje: 'Anulación por falta de pruebas'
    if confirm('¿Está seguro de anular la Solicitud?')
      $http.put(url, datos).success((data) ->
        solicitud.anulado = true
      ).error (data, status) ->
        console.log status, data
])
