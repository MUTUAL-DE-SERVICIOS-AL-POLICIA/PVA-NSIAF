$ -> new PrintBarcodes() if $('[data-action=print-barcode]').length > 0

class PrintBarcodes
  _activos = []

  constructor: ->
    @cacheElements()
    @bindEvents()
    @loadDataAndDisplay()

  cacheElements: ->
    @$barcodes_urls = $('#barcodes-urls')
    # urls
    @load_data_path = @$barcodes_urls.data('barcodes-load-data')
    @pdf_barcodes_path = @$barcodes_urls.data('barcodes-pdf')
    # containers
    @$containerPreviewBarcodes = $('#preview-barcodes')
    # buttons
    @$btnPrint = @$containerPreviewBarcodes.find('button.imprimir')
    @$btnCargar = @$containerPreviewBarcodes.find('button.cargar-barcodes')

    # Growl Notices
    @alert = new Notices({ele: 'div.main'})
    # templates
    @$templatePdfBarcode = Hogan.compile $('#tpl-barcode').html() || ''

  bindEvents: ->
    $(document).on 'click', @$btnPrint.selector, (e) => @printPdf(e)
    $(document).on 'click', @$btnCargar.selector, (e) => @cargarBarcodes(e)

  cargarBarcodes: (e)->
    e.preventDefault()
    @loadDataAndDisplay @cargarParametros()

  cargarParametros: ->
    desde: $('#barcode-desde').val() || 1
    hasta: $('#barcode-hasta').val() || 30

  displayBarcodes: ->
    @$containerPreviewBarcodes.find('.row .thumbnail .barcode').each (i, e) ->
      $(e).barcode $(e).data('barcode').toString(), 'code128', { barWidth: 1, barHeight: 50 }

  generateCodes: ->
    assets: _activos
    desde: @cargarParametros().desde
    hasta: @cargarParametros().hasta

  loadDataAndDisplay: (parametros = {})->
    $.getJSON @load_data_path, parametros, (data) =>
      _activos = data
      @previewBarcodes()
    .fail =>
      @alert.danger "Error al conectarse con el servidor, vuelva a intentarlo en unos minutos"

  previewBarcodes: ->
    @$containerPreviewBarcodes.html @$templatePdfBarcode.render(@generateCodes())
    @displayBarcodes()

  printPdf: (e)->
    e.preventDefault()
    data =
      authenticity_token: $('meta[name="csrf-token"]').attr('content')
      desde: @cargarParametros().desde
      hasta: @cargarParametros().hasta
    $.fileDownload @pdf_barcodes_path, { data: data, httpMethod: 'POST' }
