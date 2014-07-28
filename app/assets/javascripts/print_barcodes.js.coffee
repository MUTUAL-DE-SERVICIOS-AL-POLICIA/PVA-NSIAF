$ -> new PrintBarcodes() if $('[data-action=print-barcode]').length > 0

class PrintBarcodes
  _last_value = null
  _quantity = 48

  constructor: ->
    @cacheElements()
    @bindEvents()
    @loadDataAndDisplay()

  cacheElements: ->
    # urls
    @load_data_path = '/barcodes/load_data'
    @pdf_barcodes_path = '/barcodes/pdf.pdf'
    # containers
    @$containerPreviewBarcodes = $('#preview-barcodes')
    # buttons
    @$btnPrint = @$containerPreviewBarcodes.find('button[type=submit]')
    # Growl Notices
    @alert = new Notices({ele: 'div.main'})
    # templates
    @$templatePdfBarcode = Hogan.compile $('#tpl-barcode').html() || ''

  bindEvents: ->
    $(document).on 'click', @$btnPrint.selector, (e) => @printPdf(e)

  displayBarcodes: ->
    @$containerPreviewBarcodes.find('.row .thumbnail .barcode').each (i, e) ->
      $(e).barcode $(e).data('code').toString(), 'code128', { barWidth: 1, barHeight: 50 }

  generateCodes: ->
    codes = []
    acronym = _last_value.split('-')[0]
    inc = parseInt(_last_value.split('-')[1]) || 0
    if _quantity > 0
      for q in [1.._quantity]
        codes.push {code: "#{acronym}-#{q + inc}"}
      {assets: codes}
    else
      {}

  loadDataAndDisplay: ->
    $.getJSON @load_data_path, (data) =>
      _last_value = data.last_value
      @previewBarcodes()
    .fail =>
      @alert.danger "Error al conectarse con el servidor, vuelva a intentarlo en unos minutos"

  previewBarcodes: ->
    @$containerPreviewBarcodes.html @$templatePdfBarcode.render(@generateCodes())
    @displayBarcodes()

  printPdf: (e)->
    e.preventDefault()
    data =
      quantity: _quantity
      authenticity_token: $('meta[name="csrf-token"]').attr('content')
    $.fileDownload @pdf_barcodes_path, { data: data, httpMethod: 'POST' }
