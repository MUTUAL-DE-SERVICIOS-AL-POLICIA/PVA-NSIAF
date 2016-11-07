$ -> new Barcode() if $('[data-action=barcode]').length > 0

class Barcode
  _activos = []
  val = ""
  constructor: ->
    @cacheElements()
    @bindEvents()
    @loadDataAndDisplay()

  cacheElements: ->
    @$barcodes_urls = $('#barcodes-urls')
    @$InputBarCode = $('#code')
    @$containerPreviewBarcodes = $('#preview-barcodes')
    @pdf_barcodes_path = @$barcodes_urls.data('barcodes-pdf')
    @obt_cod_barra_path = @$barcodes_urls.data('barcodes-obt-cod-barra')
    @$btnNewCargar = @$containerPreviewBarcodes.find('button.Newcargar-barcode')
    @$btnPrintPdf  = @$containerPreviewBarcodes.find('button.imprimir')
    @$TxtCriteria = @$InputBarCode
    @alert = new Notices({ele: 'div.main'})
    @$templatePdfBarcode = Hogan.compile $('#tpl-barcode').html() || ''
  buscarBarCode: (e) =>
    e.preventDefault()
    _barcode = {barcode: @$InputBarCode.val()}
  bindEvents: ->
    $(document).on 'click', @$btnNewCargar.selector, (e) => @cargarBarcodes(e)
    $(document).on 'click', @$btnPrintPdf.selector,(e) => @printPdf(e)
  cargarBarcodes: (e)->
    e.preventDefault()
    @loadDataAndDisplay @cargarParametros()

  cargarParametros: ->
    searchParam : $('#code').val() || 0
  displayBarcodes: ->
    if val != 0
      $('#code').val(val)
    @$containerPreviewBarcodes.find('.row .thumbnail .barcode').each (i, e) ->
      $(e).barcode $(e).data('barcode').toString(), 'code128', { barWidth: 1, barHeight: 50 }

  generateCodes: ->
    assets: _activos
    searchParam: @cargarParametros().searchParam

  loadDataAndDisplay: (parametros = {})->
    val = @cargarParametros().searchParam
    $.getJSON @obt_cod_barra_path, parametros, (data) =>
      _activos = data
      @previewBarcodes()
    .fail =>
      @alert.danger "Error al conectarse con el servidor, vuelva a intentarlo en unos minutos"

  previewBarcodes: ->
    @$containerPreviewBarcodes.html @$templatePdfBarcode.render(@generateCodes())
    @displayBarcodes()
    $('#code').select()

  printPdf: (e)->
    e.preventDefault()
    data =
      authenticity_token: $('meta[name="csrf-token"]').attr('content')
      searchParam: @cargarParametros().searchParam || val
    $.fileDownload @pdf_barcodes_path, { data: data , httpMethod: 'POST' }
    $('#code').select()
