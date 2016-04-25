$ -> new Ingresos() if $('[data-action=ingresos]').length > 0

class Ingresos
  # lista de activos seleccionados
  _activos = []

  constructor: ->
    @cacheElements()
    @bindEvents()

  cacheElements: ->
    # Contenedor de URLs
    @$ingresosUrls = $('#ingresos-urls')
    # Variables
    @ingresosPath = @$ingresosUrls.data('activos')
    # Elementos
    @$barcode = $('#code')
    @$ingresosForm = $('#ingresos-form')
    @$ingresosTbl = $('#ingresos-tbl')
    @$buscarBtn = @$ingresosForm.find('button[type=submit]')
    # Plantillas
    @$activosTpl = Hogan.compile $('#tpl-activo-seleccionado').html() || ''
    # Growl Notices
    @alert = new Notices({ele: 'div.main'})

  bindEvents: ->
    $(document).on 'click', @$buscarBtn.selector, @buscarActivos

  adicionarEnLaLista: (data, callback) ->
    _cantidad = 0
    data.forEach (e) =>
      unless @estaEnLaLista(e)
        _cantidad += 1
        _activos.push(e)
    callback(_cantidad > 0)

  buscarActivos: (e) =>
    e.preventDefault()
    _barcode = { barcode: @$barcode.val() }
    $.getJSON @ingresosPath, _barcode, @mostrarActivos
    @$barcode.select()

  conversionNumeros: ->
    _activos.map (e) ->
      e.precio_formato = e.precio.formatNumber(2, '.', ',')
      e

  estaEnLaLista: (elemento) ->
    _activos.filter((e) ->
      e.barcode is elemento.barcode
    ).length > 0

  mostrarActivos: (data) =>
    if data.length > 0
      @adicionarEnLaLista data, (sw) =>
        if sw is true
          @mostrarTabla()
    else
      @alert.danger 'No hay resultado para mostrar'

  mostrarTabla: ->
    json =
      activos: @conversionNumeros(_activos)
      total: @sumaTotal().formatNumber(2, '.', ',')
    @$ingresosTbl.html @$activosTpl.render(json)

  sumaTotal: ->
    _activos.reduce (total, elemento) ->
      total + elemento.precio
    , 0
