jQuery ->
  barcode = new GenerateBarcodes()

class GenerateBarcodes
  asset_codes = []

  constructor: ->
    @cacheElements()
    @bindEvents()

  cacheElements: ->
    # containers
    @$queryAssets = $('#query-assets')
    @$container = $('#pdf-assets')
    @$barcodes = $('#display-pdf-assets')
    # variables
    @auxiliary_barcodes_path = '/barcodes/auxiliary.json'
    @asset_barcodes_path = '/barcodes/asset'
    @pdf_barcodes_path = '/barcodes/pdf.pdf'
    # selects, checkboxes, buttons
    @$account = $('#account')
    @$auxiliary = $('#auxiliary')
    @$assetAll = $('#asset_all')
    @$checkboxes = @$container.find('table tbody td input[type=checkbox]')
    @$btnPrint = $('#btn-print')
    @$btnPrintPdf = $('#btn-print-pdf')
    @$btnCancelPdf = $('#btn-cancel-pdf')
    # templates
    @$assetTpl = Hogan.compile $('#tpl-pdf-assets').html() || ''
    @$barcodeTpl = Hogan.compile $('#tpl-barcode').html() || ''

  bindEvents: ->
    @$auxiliary.remoteChained(@$account.selector, @auxiliary_barcodes_path)
    $(document).on 'change', @$account.selector, => @getAccounts()
    $(document).on 'change', @$auxiliary.selector, => @getAccounts()
    $(document).on 'change', @$assetAll.selector, => @selectAllAssets()
    $(document).on 'change', @$checkboxes.selector, (e) => @selectAsset(e)
    $(document).on 'click', @$btnPrint.selector, (e) => @displayBarcodes(e)
    $(document).on 'click', @$btnCancelPdf.selector, (e) => @showFilter(e)
    $(document).on 'click', @$btnPrintPdf.selector, (e) => @printPdf(e)

  getAccounts: ->
    account_id = @$account.val()
    auxiliary_id = @$auxiliary.val()
    @getDataAccounts(account_id, auxiliary_id) if account_id || auxiliary_id

  getDataAccounts: (account_id, auxiliary_id) ->
    data = { account: account_id, auxiliary: auxiliary_id }
    $.getJSON @asset_barcodes_path, data, (data) => @displayAccounts(data)
    @asset_codes = []

  displayAccounts: (data) ->
    html = @$assetTpl.render(data)
    @$container.html(html)

  displayBarcodes: (e) ->
    e.preventDefault()
    if @asset_codes.length > 0
      @$queryAssets.hide()
      data = { assets: $.map @asset_codes, (e, i) -> { code: e } }
      html = @$barcodeTpl.render(data)
      @$barcodes.html(html).show()
      @generateBarcodes()
    else
      alert 'Debe seleccionar al menos un Activo'

  generateBarcodes: ->
    @$barcodes.find('.row .thumbnail .barcode').each (i, e) ->
      $(e).barcode $(e).data('code').toString(), 'code128', { barWidth: 1, barHeight: 50 }

  printPdf: ->
    data =
      asset_codes: @asset_codes
      authenticity_token: $('meta[name="csrf-token"]').attr('content')
    $.fileDownload @pdf_barcodes_path, { data: data, httpMethod: 'POST' }

  selectAllAssets: ->
    $checkboxes = @$container.find('table tbody td input[type=checkbox]')
    if $(@$assetAll.selector).is(':checked')
      $checkboxes.prop('checked', true)
      @asset_codes = $.map $checkboxes, (e) -> $(e).val()
    else
      $checkboxes.prop('checked', false)
      @asset_codes = []

  selectAsset: (e) ->
    $input = $(e.target)
    val = $input.val()
    if $input.is(':checked')
      @asset_codes.push(val)
    else
      @asset_codes = jQuery.grep @asset_codes, (value) -> value != val

  showFilter: (e) ->
    e.preventDefault()
    @$barcodes.html('').hide()
    @$queryAssets.show()
