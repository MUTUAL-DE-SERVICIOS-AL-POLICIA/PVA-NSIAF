$ -> new PrintBarcodes() if $('[data-action=print-barcode]').length > 0

class PrintBarcodes
  _last_value = null
  _first_value = null
  _quantity = 0

  constructor: ->
    @cacheElements()
    @bindEvents()

  cacheElements: ->
    # variables
    _first_value = $('h4 span.from').text()
    _last_value = $('h4 span.to').text()
    # containers
    @$containerPreviewBarcodes = $('#preview-barcodes')
    # Growl Notices
    @alert = new Notices({ele: 'div.main'})
    # inputs
    $form = $('form')
    @$btnPreview = $form.find('button[type=submit]')
    @$txtQuantity = $form.find('input[type=text]')
    # templates
    @$templatePdfBarcode = Hogan.compile $('#tpl-barcode').html() || ''

  bindEvents: ->
    $(document).on 'click', @$btnPreview.selector, (e) => @previewBarcodes(e)

  displayBarcodes: ->
    @$containerPreviewBarcodes.find('.row .thumbnail .barcode').each (i, e) ->
      $(e).barcode $(e).data('code').toString(), 'code128', { barWidth: 1, barHeight: 50 }

  generateCodes: ->
    codes = []
    inc = parseInt(_last_value.split('-')[1]) || 0
    if _quantity > 0
      for q in [1.._quantity]
        codes.push {code: "ADSIB-#{q + inc}"}
      {assets: codes}
    else
      {}

  getQuantity: ->
    _quantity = parseInt(@$txtQuantity.val()) || 0

  previewBarcodes: (e) ->
    e.preventDefault()
    if @getQuantity() > 0
      @$containerPreviewBarcodes.html @$templatePdfBarcode.render(@generateCodes())
      @$containerPreviewBarcodes.show()
      @displayBarcodes()
    else
      @alert.info "La cantidad a imprimir tiene que ser mayor a cero"
