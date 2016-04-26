$ -> new Ingresos() if $('[data-action=ingresos]').length > 0

class Ingresos
  # lista de activos seleccionados
  _activos = []
  _proveedor = {}
  _factura = {}
  _nota_entrega = {}
  _c31 = {}

  constructor: ->
    @cacheElements()
    @bindEvents()

  cacheElements: ->
    # Contenedor de URLs
    @$ingresosUrls = $('#ingresos-urls')
    # Variables
    @ingresosPath = @$ingresosUrls.data('activos')
    @proveedoresPath = @$ingresosUrls.data('proveedores')
    # Elementos
    @$barcode = $('#code')
    @$facturaForm = $('#factura-form')
    @$ingresosForm = $('#ingresos-form')
    @$proveedorAuto = @$facturaForm.find('.proveedor-auto')
    @$ingresosTbl = $('#ingresos-tbl')
    @$proveedorTbl = $('#proveedor-tbl')
    @$buscarBtn = @$ingresosForm.find('button[type=submit]')
    # Campos
    @$proveedorNombre = @$facturaForm.find('#proveedor')
    @$proveedorNit = @$facturaForm.find('#nit')
    @$proveedorTelefono = @$facturaForm.find('#telefono')
    @$facturaNumero = @$facturaForm.find('#factura_numero')
    @$facturaAutorizacion = @$facturaForm.find('#factura_autorizacion')
    @$facturaFecha = @$facturaForm.find('#factura_fecha')
    @$notaEntregaFecha = @$facturaForm.find('#nota_entrega_fecha')
    @$c31Numero = @$facturaForm.find('#c31_numero')
    @$c31Fecha = @$facturaForm.find('#c31_fecha')
    # Plantillas
    @$activosTpl = Hogan.compile $('#tpl-activo-seleccionado').html() || ''
    @$proveedorTpl = Hogan.compile $('#tpl-datos-proveedor').html() || ''
    # Growl Notices
    @alert = new Notices({ele: 'div.main'})

  bindEvents: ->
    if @$proveedorAuto?
      @proveedorAutocomplete()
    $(document).on 'click', @$buscarBtn.selector, @buscarActivos
    $(document).on 'keyup', @$proveedorNombre.selector, @capturarProveedor
    $(document).on 'keyup', @$proveedorNit.selector, @capturarProveedor
    $(document).on 'keyup', @$proveedorTelefono.selector, @capturarProveedor
    $(document).on 'keyup', @$facturaNumero.selector, @capturarFactura
    $(document).on 'keyup', @$facturaAutorizacion.selector, @capturarFactura
    $(document).on 'change', @$facturaFecha.selector, @capturarFactura
    $(document).on 'change', @$notaEntregaFecha.selector, @capturarNotaEntrega
    $(document).on 'keyup', @$c31Numero.selector, @capturarC31
    $(document).on 'change', @$c31Fecha.selector, @capturarC31

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

  capturarC31: =>
    _c31.c31_numero = @$c31Numero.val().trim()
    _c31.c31_fecha = @$c31Fecha.val().trim()
    @mostrarDatosProveedor()

  capturarFactura: =>
    _factura.factura_numero = @$facturaNumero.val().trim()
    _factura.factura_autorizacion = @$facturaAutorizacion.val().trim()
    _factura.factura_fecha = @$facturaFecha.val()
    @mostrarDatosProveedor()

  capturarNotaEntrega: =>
    _nota_entrega.nota_entrega_fecha = @$notaEntregaFecha.val().trim()
    @mostrarDatosProveedor()

  capturarProveedor: =>
    _proveedor.name = @$proveedorNombre.val().trim()
    _proveedor.nit = @$proveedorNit.val().trim()
    _proveedor.telefono = @$proveedorTelefono.val().trim()
    @mostrarDatosProveedor()

  cargarDatosProveedor: ->
    @$proveedorNit.val _proveedor.nit
    @$proveedorTelefono.val _proveedor.telefono

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

  mostrarDatosProveedor: ->
    json =
      proveedor: _proveedor
      factura: _factura
      nota_entrega: _nota_entrega
      c31: _c31
    @$proveedorTbl.html @$proveedorTpl.render(json)

  mostrarTabla: ->
    json =
      activos: @conversionNumeros(_activos)
      total: @sumaTotal().formatNumber(2, '.', ',')
    @$ingresosTbl.html @$activosTpl.render(json)

  proveedorAutocomplete: ->
    proveedores = new Bloodhound(
      datumTokenizer: Bloodhound.tokenizers.obj.whitespace("description")
      queryTokenizer: Bloodhound.tokenizers.whitespace
      limit: 10
      remote: decodeURIComponent(@proveedoresPath)
    )
    proveedores.initialize()
    @$proveedorAuto.typeahead null,
      displayKey: "name"
      source: proveedores.ttAdapter()
    .on 'typeahead:selected', @seleccionarProveedor

  seleccionarProveedor: (evt, proveedor) =>
    _proveedor = proveedor
    @cargarDatosProveedor()
    # @mostrarDatosProveedor()

  sumaTotal: ->
    _activos.reduce (total, elemento) ->
      total + elemento.precio
    , 0
