jQuery ->
  barcode = new GenerateBarcodes()

class GenerateBarcodes
  asset_ids = []

  constructor: ->
    @cacheElements()
    @bindEvents()

  cacheElements: ->
    # containers
    @$queryAssets = $('#query-assets')
    @$container = $('#pdf-assets')
    @$barcodes = $('#display-pdf-assets')
    # variables
    @$assets_path = '/barcodes/asset'
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
    @$auxiliary.remoteChained(@$account.selector, '/barcodes/auxiliary.json')
    $(document).on 'change', @$account.selector, => @getAccounts()
    $(document).on 'change', @$auxiliary.selector, => @getAccounts()
    $(document).on 'change', @$assetAll.selector, => @selectAllAssets()
    $(document).on 'change', @$checkboxes.selector, (e) => @selectAsset(e)
    $(document).on 'click', @$btnPrint.selector, (e) => @displayBarcodes(e)
    $(document).on 'click', @$btnCancelPdf.selector, (e) => @showFilter(e)

  getAccounts: ->
    account_id = @$account.val()
    auxiliary_id = @$auxiliary.val()
    @getDataAccounts(account_id, auxiliary_id) if account_id || auxiliary_id

  getDataAccounts: (account_id, auxiliary_id) ->
    data = { account: account_id, auxiliary: auxiliary_id }
    $.getJSON @$assets_path, data, (data) => @displayAccounts(data)
    @asset_ids = []

  displayAccounts: (data) ->
    html = @$assetTpl.render(data)
    @$container.html(html)

  displayBarcodes: (e) ->
    e.preventDefault()
    if @asset_ids.length > 0
      @$queryAssets.hide()
      data = { assets: $.map @asset_ids, (e, i) -> { code: e } }
      html = @$barcodeTpl.render(data)
      @$barcodes.html(html).show()
      @generateBarcodes()
    else
      alert 'Debe seleccionar al menos un Activo'

  generateBarcodes: ->
    @$barcodes.find('.row .thumbnail .barcode').each (i, e) ->
      $(e).barcode $(e).data('code').toString(), 'code128', { barWidth: 1, barHeight: 50 }

  selectAllAssets: ->
    $checkboxes = @$container.find('table tbody td input[type=checkbox]')
    if $(@$assetAll.selector).is(':checked')
      $checkboxes.prop('checked', true)
      @asset_ids = $.map $checkboxes, (e) -> $(e).val()
    else
      $checkboxes.prop('checked', false)
      @asset_ids = []

  selectAsset: (e) ->
    $input = $(e.target)
    val = $input.val()
    if $input.is(':checked')
      @asset_ids.push(val)
    else
      @asset_ids = jQuery.grep @asset_ids, (value) -> value != val

  showFilter: (e) ->
    e.preventDefault()
    @$barcodes.html('').hide()
    @$queryAssets.show()
