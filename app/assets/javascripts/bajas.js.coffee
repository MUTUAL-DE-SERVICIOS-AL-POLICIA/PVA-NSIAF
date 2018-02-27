$ -> new Bajas() if $('[data-action=bajas]').length > 0

class Bajas
  # lista de activos seleccionados
  _activos = []
  _baja = {}

  constructor: ->
    @cacheElements()
    @bindEvents()

  cacheElements: ->
    # Contenedor de URLs
    @$ingresosUrls = $('#ingresos-urls')
    # Variables
    @ingresosPath = @$ingresosUrls.data('bajas')
    @proveedoresPath = @$ingresosUrls.data('proveedores')
    @$obt_ingreso_urls = $('#obt_ingreso-urls')
    @obt_ingreso_url = @$obt_ingreso_urls.data('obt-ingreso')
    @id_ingreso = @$obt_ingreso_urls.data('ingreso')
    # Elementos
    @$barcode = $('#code')
    @$documento = $('#documento')
    @$fecha = $('#fecha')
    @$observacion = $('#observacion_')


    @$facturaForm = $('#factura-form')
    @$ingresosForm = $('#ingresos-form')
    @$ingresosTbl = $('#ingresos-tbl')
    @$proveedorTbl = $('#proveedor-tbl')
    @$buscarBtn = @$ingresosForm.find('button[type=submit]')
    @$guardarBtn = $('.guardar-btn')
    # Plantillas
    @$activosTpl = Hogan.compile $('#tpl-activo-seleccionado').html() || ''
    # Growl Notices
    @alert = new Notices({ele: 'div.main'})

    @$confirmModal = $('#confirm-modal')
    @$confirmarIngresoModal = $('#modal-confirmar-ingreso')
    @$alertaIngresoModal = $('#modal-alerta-ingreso')

    # Plantillas
    @$confirmarIngresoTpl = Hogan.compile $('#confirmar-ingreso-tpl').html() || ''
    @$alertaIngresoTpl = Hogan.compile $('#alerta-ingreso-tpl').html() || ''

  bindEvents: ->
    $(document).on 'click', @$buscarBtn.selector, @buscarActivos
    $(document).on 'change', @$documento.selector, @capturarBaja
    $(document).on 'change', @$fecha.selector, @capturarBaja
    $(document).on 'change', @$observacion.selector, @capturarBaja

    $(document).on 'click', @$guardarBtn.selector, @confirmarIngreso
    $(document).on 'click', @$confirmarIngresoModal.find('button[type=submit]').selector, (e) => @validarObservacion(e)

  confirmarIngreso: (e) =>
    e.preventDefault()
    if @sonValidosDatos()
      @$confirmModal.html @$confirmarIngresoTpl.render({})
      modal = @$confirmModal.find(@$confirmarIngresoModal.selector)
      modal.modal('show')
    else
      @alert.danger "Complete todos los datos requeridos"

  aceptarConfirmarModal: (e) =>
    e.preventDefault()
    el = @$confirmModal.find('#modal_observacion')
    @$confirmModal.find(@$confirmarIngresoModal.selector).modal('hide')
    $form = $(e.target).closest('form')
    @guardarIngresoActivosFijos(e)

  validarObservacion: (e) =>
    el = @$confirmModal.find('#modal_observacion')
    if el
      el.parents('.form-group').removeClass('has-error')
      el.next().remove()
      @aceptarConfirmarModal(e)

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

  capturarBaja: =>
    console.log('captando datos')
    _baja.documento = @$documento.val().trim()
    _baja.fecha = @$fecha.val().trim()
    _baja.observacion = @$observacion.val().trim()

  conversionNumeros: ->
    _activos.map (e, i) ->
      e.indice = i + 1
      e.precio_formato = parseFloat(e.precio).formatNumber(2, '.', ',')
      e

  estaEnLaLista: (elemento) ->
    _activos.filter((e) ->
      e.barcode is elemento.barcode
    ).length > 0

  guardarIngresoActivosFijos: (e) ->
    if @sonValidosDatos()
      $(e.target).addClass('disabled')
      $.ajax
        url: @ingresosPath
        type: 'POST'
        dataType: 'JSON'
        data: { baja: @jsonIngreso() }
      .done (baja) =>
        @alert.success "Se guardó correctamente la Baja"
        window.location = "#{@ingresosPath}/#{baja.id}"
      .fail (xhr, status) =>
        @alert.danger 'Error al guardar la Baja'
      .always (xhr, status) ->
        $(e.target).removeClass('disabled')
    else
      @alert.danger "Complete todos los datos requeridos"

  jsonIngreso: ->
    baja =
      asset_ids: _activos.map((e) -> e.id)
      documento: @$documento.val()
      fecha: @$fecha.val()
      observacion: @$observacion.val()
    $.extend({}, baja)

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
      cantidad: _activos.length
      total: @sumaTotal().formatNumber(2, '.', ',')
    @$ingresosTbl.html @$activosTpl.render(json)

  sonValidosDatos: ->
    _activos.length > 0 && @$documento.val() && @$fecha.val() && @$observacion.val()

  sumaTotal: ->
    _activos.reduce (total, elemento) ->
      total + parseFloat(elemento.precio)
    , 0
