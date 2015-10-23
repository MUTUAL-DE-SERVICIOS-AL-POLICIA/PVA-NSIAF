almacenes = angular.module('almacenes', [])

almacenes.controller('EntradasCtrl', ['$scope', ($scope) ->

  $scope.notas_entrada = [
    {
      id: '1',
      nro: '001',
      empresa: 'Empresa SRL',
      encargado: 'Roxana Gomez',
      fecha: '2015-01-01',
      total: 200.33,
      nota_entrega_nro: '200',
      factura_nro: '0012345',
      creado_el: '2015-10-14T15:30:00-0400'
    },
    {
      id: '2',
      nro: '002',
      empresa: 'Empresa SRL',
      encargado: 'Roxana Gomez',
      fecha: '2015-10-14',
      total: 200.33,
      nota_entrega_nro: '200',
      factura_nro: '0012345',
      creado_el: '2015-10-14T15:30:00-0400'
    },
    {
      id: '3',
      nro: '003',
      empresa: 'Empresa SRL',
      encargado: 'Roxana Gomez',
      fecha: '2015-10-14',
      total: 200.33,
      nota_entrega_nro: '200',
      factura_nro: '0012345',
      creado_el: '2015-10-14T15:30:00-0400'
    },
    {
      id: '4',
      nro: '004',
      empresa: 'Empresa SRL',
      encargado: 'Roxana Gomez',
      fecha: '2015-10-14',
      total: 200.33,
      nota_entrega_nro: '200',
      factura_nro: '0012345',
      creado_el: '2015-10-14T15:30:00-0400'
    }
  ]

])
