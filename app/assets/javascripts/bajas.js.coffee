$ -> new Bajas() if $('[data-action=bajas]').length > 0

class Bajas
  # lista de activos seleccionados
  _activos = []
  _baja = {}
  alert 'bajas'

  constructor: ->
    @cacheElements()
    @bindEvents()

  cacheElements: ->
    # Contenedor de URLs
    @$bajasUrls = $('#bajas-urls')
    # Variables
    @ingresosPath = @$bajasUrls.data('activos')
    @proveedoresPath = @$bajasUrls.data('proveedores')
    @$obt_ingreso_urls = $('#obt_ingreso-urls')
    @obt_ingreso_url = @$obt_ingreso_urls.data('obt-ingreso')
    @id_ingreso = @$obt_ingreso_urls.data('ingreso')
    # Elementos
    @$barcode = $('#code')
    @$bajaForm = $('#baja-form')
    @$busquedaForm = $('#busqueda-form')
    @$ingresosTbl = $('#ingresos-tbl')
    @$proveedorTbl = $('#proveedor-tbl')
    @$buscarBtn = @$busquedaForm.find('button[type=submit]')
    @$guardarBtn = $('.guardar-btn')
    # Campos
    @$bajaDocumento = @$bajaForm.find('#documento')
    @$bajaFecha = @$bajaForm.find('#fecha')
    @$bajaObservacion = @$bajaForm.find('#observacion')

    @$proveedorNit = @$facturaForm.find('#nit')
    @$proveedorTelefono = @$facturaForm.find('#telefono')
    @$facturaNumero = @$facturaForm.find('#factura_numero')
    @$facturaAutorizacion = @$facturaForm.find('#factura_autorizacion')
    @$facturaFecha = @$facturaForm.find('#factura_fecha')
    @$notaEntregaNumero = @$facturaForm.find('#nota_entrega_numero')
    @$notaEntregaFecha = @$facturaForm.find('#nota_entrega_fecha')
    @$c31Numero = @$facturaForm.find('#c31_numero')
    @$c31Fecha = @$facturaForm.find('#c31_fecha')
    @$inputObservacion = $('#observacion')
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

    $(document).on 'change', @$bajaDocumento.selector, @capturaBaja
    $(document).on 'change', @$bajaFecha.selector, @capturaBaja
    $(document).on 'change', @$bajaObservacion.selector, @capturaBaja

    $(document).on 'click', @$guardarBtn.selector, @confirmarIngreso
    $(document).on 'click', @$confirmarIngresoModal.find('button[type=submit]').selector, (e) => @validarObservacion(e)
    $(document).on 'click', @$alertaIngresoModal.find('button[type=submit]').selector, (e) => @aceptarAlertaIngreso(e)

  confirmarIngreso: (e) =>
    alert 'baja'
    e.preventDefault()
    if @sonValidosDatos()
      # if @id_ingreso
      #   url = @obt_ingreso_url + "?d=" + $("#factura_fecha").val() + '&n=' + @id_ingreso
      # else
      #   url = @obt_ingreso_url + "?d=" + $("#factura_fecha").val()
      @guardarBajasActivosFijos(e)
      # $.ajax
      #   url: url
      #   type: 'GET'
      #   dataType: 'JSON'
      # .done (xhr) =>
      #   data = xhr
      #   if data["tipo_respuesta"]
      #     if data["tipo_respuesta"] == "confirmacion"
      #       @$confirmModal.html @$confirmarIngresoTpl.render(data)
      #       modal = @$confirmModal.find(@$confirmarIngresoModal.selector)
      #       modal.modal('show')
      #     else if data["tipo_respuesta"] == "alerta"
      #       @$confirmModal.html @$alertaIngresoTpl.render(data)
      #       modal = @$confirmModal.find(@$alertaIngresoModal.selector)
      #       modal.modal('show')
      #   else
      #     @guardarIngresoActivosFijos(e)
    else
      @alert.danger "Complete todos los datos requeridos"

  aceptarConfirmarIngreso: (e) =>
    e.preventDefault()
    el = @$confirmModal.find('#modal_observacion')
    if el
      @$inputObservacion.val(el.val())
    @capturarObservacion()
    @$confirmModal.find(@$confirmarIngresoModal.selector).modal('hide')
    $form = $(e.targetingresosPath).closest('form')
    @guardarBajasActivosFijos(e)

  validarObservacion: (e) =>
    el = @$confirmModal.find('#modal_observacion')
    if el
      valor = $.trim(el.val())
      if valor
        el.parents('.form-group').removeClass('has-error')
        el.next().remove()
        @aceptarConfirmarIngreso(e)
      else
        el.parents('.form-group').addClass('has-error')
        el.after('<span class="help-block">no puede estar en blanco</span>') unless $('span.help-block').length
        false

  aceptarAlertaIngreso: (e) ->
    e.preventDefault()
    @$confirmModal.find(@$alertaIngresoModal.selector).modal('hide')
    $form = $(e.target).closest('form')
    false

  adicionarEnLaLista: (data, callback) ->
    _cantidad = 0
    data.forEach (e) =>
      unless @estaEnLaLista(e)
        _cantidad += 1
        _activos.push(e)
    callback(_cantidad > 0)

  buscarActivos: (e) =>
    alert('presionando')
    e.preventDefault()
    debugger
    _barcode = { barcode: @$barcode.val() }
    $.getJSON @ingresosPath, _barcode, @mostrarActivos
    @$barcode.select()

  capturaBaja: =>
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

  guardarBajasActivosFijos: (e) =>
    if @sonValidosDatos()
      @jsonBaja()
      debugger
      $(e.target).addClass('disabled')
      $.ajax
        url: @ingresosPath
        type: 'POST'
        dataType: 'JSON'
        data: { baja: @jsonBaja() }
      .done (ingreso) =>
        @alert.success "Se guardó correctamente la Nota de Ingreso"
        window.location = "#{@ingresosPath}/#{ingreso.id}"
      .fail (xhr, status) =>
        @alert.danger 'Error al guardar Nota de Ingreso'
      .always (xhr, status) ->
        $(e.target).removeClass('disabled')
    else
      @alert.danger "Complete todos los datos requeridos"

  jsonBaja: ->
    baja =
      asset_ids: _activos.map((e) -> e.id)
      documento: _baja.documento
      fecha: _baja.fecha
      observacion: _baja.observacion
    $.extend({}, bajas)

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
    _activos.length > 0

  sumaTotal: ->
    _activos.reduce (total, elemento) ->
      total + parseFloat(elemento.precio)
    , 0
