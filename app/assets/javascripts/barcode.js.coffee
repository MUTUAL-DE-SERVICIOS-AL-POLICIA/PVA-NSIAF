$ -> new Barcode() if $('[data-action=barcode]').length > 0

class Barcode
  _activos = []
  _codigo = ''

  constructor: ->
    @cacheElements()
    @bindEvents()
    @loadDataAndDisplay()

  cacheElements: ->
    @cacheElementsHogan()
    @$barcodes_urls = $('#barcodes-urls')
    @$containerPreviewBarcodes = $('#preview-barcodes')
    @pdf_barcodes_path = @$barcodes_urls.data('barcodes-pdf')
    @obt_cod_barra_path = @$barcodes_urls.data('barcodes-obt-cod-barra')
    @$btnNewCargar = @$containerPreviewBarcodes.find('button.Newcargar-barcode')
    @$btnPrintPdf  = @$containerPreviewBarcodes.find('button.imprimir')
    @alert = new Notices({ele: 'div.main'})
    @$templatePdfBarcode = Hogan.compile $('#tpl-barcode').html() || ''

  cacheElementsHogan: ->
    @$InputBarCode = $('#code')

  buscarBarCode: (e) =>
    e.preventDefault()
    _barcode = {barcode: @$InputBarCode.val()}

  bindEvents: ->
    $(document).on 'click', @$btnNewCargar.selector, (e) => @cargarBarcodes(e)
    $(document).on 'click', @$btnPrintPdf.selector,(e) => @printPdf(e)

  cargarBarcodes: (e) =>
    e.preventDefault()
    @loadDataAndDisplay @cargarParametros()

  cargarParametros: =>
    searchParam: @$InputBarCode.val() || 0

  displayBarcodes: =>
    if _codigo != 0
      @$InputBarCode.val(_codigo)
    @$containerPreviewBarcodes.find('.row .thumbnail .barcode').each (i, e) ->
      $(e).barcode $(e).data('barcode').toString(), 'code128', { barWidth: 1, barHeight: 50 }

  generateCodes: =>
    assets: _activos
    searchParam: @cargarParametros().searchParam

  loadDataAndDisplay: (parametros = {}) =>
    _codigo = @cargarParametros().searchParam
    $.getJSON @obt_cod_barra_path, parametros, (data) =>
      _activos = data
      @previewBarcodes()
    .fail =>
      @alert.danger "Error al conectarse con el servidor, vuelva a intentarlo en unos minutos"

  previewBarcodes: =>
    @$containerPreviewBarcodes.html @$templatePdfBarcode.render(@generateCodes())
    @cacheElementsHogan()
    @displayBarcodes()
    @$InputBarCode.select()

  printPdf: (e) =>
    e.preventDefault()
    data =
      authenticity_token: $('meta[name="csrf-token"]').attr('content')
      searchParam: @cargarParametros().searchParam || _codigo
    $.fileDownload @pdf_barcodes_path, { data: data , httpMethod: 'POST' }
    @$InputBarCode.select()
