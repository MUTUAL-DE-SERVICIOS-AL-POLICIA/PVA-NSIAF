$ -> new Seguros() if $('[data-action=seguros]').length > 0

class Seguros
  # lista de activos seleccionados
  _activos = []
  _proveedor = {}
  _factura = {}
  _contrato = {}

  constructor: ->
    @cacheElements()
    @bindEvents()

  cacheElements: ->
    # Contenedor de URLs
    @$segurosUrls = $('#seguros-urls')
    # Variables
    @segurosPath = @$segurosUrls.data('seguros')
    @proveedoresPath = @$segurosUrls.data('proveedores')

    @$obt_ingreso_urls = $('#obt_ingreso-urls')
    @obt_ingreso_url = @$obt_ingreso_urls.data('obt-ingreso')
    @id_ingreso = @$obt_ingreso_urls.data('ingreso')
    # Elementos
    @$barcode = $('#code')
    @$facturaForm = $('#factura-form')
    @$ingresosForm = $('#ingresos-form')
    @$proveedorAuto = @$facturaForm.find('.proveedor-auto')
    @$ingresosTbl = $('#ingresos-tbl')
    @$proveedorTbl = $('#proveedor-tbl')
    @$buscarBtn = @$ingresosForm.find('button[type=submit]')
    @$guardarBtn = $('.guardar-btn')
    # Campos
    @$proveedorNombre = @$facturaForm.find('#proveedor')
    @$proveedorNit = @$facturaForm.find('#nit')
    @$proveedorTelefono = @$facturaForm.find('#telefono')
    @$facturaNumero = @$facturaForm.find('#factura_numero')
    @$facturaAutorizacion = @$facturaForm.find('#factura_autorizacion')
    @$facturaFecha = @$facturaForm.find('#factura_fecha')
    @$numeroContrato = @$facturaForm.find('#numero_contrato')
    @$fechaInicioVigencia = @$facturaForm.find('#fecha_inicio_vigencia')
    @$fechaFinVigencia = @$facturaForm.find('#fecha_fin_vigencia')
    # Plantillas
    @$activosTpl = Hogan.compile $('#tpl-activo-seleccionado').html() || ''
    # Growl Notices
    @alert = new Notices({ele: 'div.main'})

  bindEvents: ->
    if @$proveedorAuto?
      @proveedorAutocomplete()
    $(document).on 'click', @$buscarBtn.selector, @buscarActivos
    $(document).on 'change', @$proveedorNombre.selector, @capturarProveedor
    $(document).on 'change', @$proveedorNit.selector, @capturarProveedor
    $(document).on 'change', @$proveedorTelefono.selector, @capturarProveedor
    $(document).on 'change', @$facturaNumero.selector, @capturarFactura
    $(document).on 'change', @$facturaAutorizacion.selector, @capturarFactura
    $(document).on 'change', @$facturaFecha.selector, @capturarFactura
    $(document).on 'change', @$numeroContrato.selector, @capturarContrato
    $(document).on 'change', @$fechaInicioVigencia.selector, @capturarContrato
    $(document).on 'change', @$fechaFinVigencia.selector, @capturarContrato
    $(document).on 'click', @$guardarBtn.selector, @guardarSeguros

  confirmarIngreso: (e) =>
    e.preventDefault()
    if @sonValidosDatos()
      if @id_ingreso
        url = @obt_ingreso_url + "?d=" + $("#factura_fecha").val() + '&n=' + @id_ingreso
      else
        url = @obt_ingreso_url + "?d=" + $("#factura_fecha").val()
      $.ajax
        url: url
        type: 'GET'
        dataType: 'JSON'
      .done (xhr) =>
        data = xhr
        if data["tipo_respuesta"]
          if data["tipo_respuesta"] == "confirmacion"
            @$confirmModal.html @$confirmarIngresoTpl.render(data)
            modal = @$confirmModal.find(@$confirmarIngresoModal.selector)
            modal.modal('show')
          else if data["tipo_respuesta"] == "alerta"
            @$confirmModal.html @$alertaIngresoTpl.render(data)
            modal = @$confirmModal.find(@$alertaIngresoModal.selector)
            modal.modal('show')
        else
          @guardarIngresoActivosFijos(e)
    else
      @alert.danger "Complete todos los datos requeridos"

  aceptarConfirmarIngreso: (e) =>
    e.preventDefault()
    el = @$confirmModal.find('#modal_observacion')
    if el
      @$inputObservacion.val(el.val())
    @capturarObservacion()
    @$confirmModal.find(@$confirmarIngresoModal.selector).modal('hide')
    $form = $(e.target).closest('form')
    @guardarIngresoActivosFijos(e)

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
    e.preventDefault()
    _barcode = { barcode: @$barcode.val() }
    $.getJSON @segurosPath, _barcode, @mostrarActivos
    @$barcode.select()

  capturarFactura: =>
    _factura.factura_numero = @$facturaNumero.val().trim()
    _factura.factura_autorizacion = @$facturaAutorizacion.val().trim()
    _factura.factura_fecha = @$facturaFecha.val()

  capturarContrato: =>
    _contrato.numero_contrato = @$numeroContrato.val().trim()
    _contrato.fecha_inicio_vigencia = @$fechaInicioVigencia.val().trim()
    _contrato.fecha_fin_vigencia = @$fechaFinVigencia.val().trim()

  capturarProveedor: =>
    _proveedor.name = @$proveedorNombre.val().trim()
    _proveedor.nit = @$proveedorNit.val().trim()
    _proveedor.telefono = @$proveedorTelefono.val().trim()

  cargarDatosProveedor: ->
    @$proveedorNit.val _proveedor.nit
    @$proveedorTelefono.val _proveedor.telefono

  conversionNumeros: ->
    _activos.map (e, i) ->
      e.indice = i + 1
      e.precio_formato = parseFloat(e.precio).formatNumber(2, '.', ',')
      e

  estaEnLaLista: (elemento) ->
    _activos.filter((e) ->
      e.barcode is elemento.barcode
    ).length > 0

  guardarSeguros: (e) =>
    if @sonValidosDatos()
      $(e.target).addClass('disabled')
      $.ajax
        url: @segurosPath
        type: 'POST'
        dataType: 'JSON'
        data: { seguro: @jsonSeguro() }
      .done (seguro) =>
        @alert.success "Se guardó correctamente el seguro"
        window.location = "#{@segurosPath}/#{seguro.id}"
      .fail (xhr, status) =>
        @alert.danger 'Error al guardar el seguro'
      .always (xhr, status) ->
        $(e.target).removeClass('disabled')
    else
      @alert.danger "Complete todos los datos requeridos"

  jsonSeguro: ->
    seguro =
      asset_ids: _activos.map((e) -> e.id)
      supplier_id: _proveedor.id
    seguro = $.extend({}, seguro, _factura)
    seguro = $.extend({}, seguro, _contrato)

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

  sonValidosDatos: ->
    _activos.length > 0

  sumaTotal: ->
    _activos.reduce (total, elemento) ->
      total + parseFloat(elemento.precio)
    , 0
