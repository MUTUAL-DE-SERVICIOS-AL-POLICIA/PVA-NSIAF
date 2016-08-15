$ -> new Reportes() if $('[data-action=reportes]').length > 0

class Reportes

  constructor: ->
    @cacheElements()
    @bindEvents()

  cacheElements: ->
    @$descargarKardexBtn = $('.descargar-kardex')

  bindEvents: ->
    $(document).on 'click', @$descargarKardexBtn.selector, @deshabilitarBoton

  deshabilitarBoton: (event) ->
    $(event.target).addClass('disabled')
