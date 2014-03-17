jQuery ->
  barcode = new GenerateBarcodes()

class GenerateBarcodes
  constructor: ->
    @cacheElements()
    @bindEvents()

  cacheElements: ->
    # containers
    @$container = $('#pdf-assets')
    # variables
    @$assets_path = '/barcodes/asset'
    # selects
    @$account = $('#account')
    @$auxiliary = $('#auxiliary')
    # templates
    @$assetTpl = Hogan.compile $('#tpl-pdf-assets').html() || ''

  bindEvents: ->
    @$auxiliary.remoteChained(@$account.selector, '/barcodes/auxiliary.json')
    $(document).on 'change', @$account.selector, => @getAccounts()
    $(document).on 'change', @$auxiliary.selector, => @getAccounts()

  getAccounts: ->
    account_id = @$account.val()
    auxiliary_id = @$auxiliary.val()
    @getDataAccounts(account_id, auxiliary_id) if account_id || auxiliary_id

  getDataAccounts: (account_id, auxiliary_id) ->
    data = { account: account_id, auxiliary: auxiliary_id }
    $.getJSON @$assets_path, data, (data) => @displayAccounts(data)

  displayAccounts: (data) ->
    html = @$assetTpl.render(data)
    @$container.html(html)
