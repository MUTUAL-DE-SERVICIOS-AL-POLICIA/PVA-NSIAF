$ -> new Devolutions()

class Devolutions extends BarcodeReader
  _assets = []
  _user = null

  constructor: ->
    @cacheElements()
    @bindEvents()

  cacheElements: ->
    $form = $('form[data-action=devolution]')
    # URLs
    @assets_search_url = '/assets/search'
    @proceedings_url = '/proceedings'
    # Containers
    @$containerTplSelectedAssets = $('#container-tpl-selected-assets')
    @$containerTplSelectedUser = $('#container-tpl-selected-user')
    # textfields
    @$code = $form.find('input[type=text]')
    # buttons
    @$btnContinue = @$containerTplSelectedAssets.find('button[data-type=continue]')
    @$btnSave = @$containerTplSelectedAssets.find('button[data-type=save]')
    @$btnSend = $form.find('button[type=submit]')
    # Growl Notices
    @alert = new Notices({ele: 'div.main'})
    # Hogan templates
    @$templateSelectedAssets = Hogan.compile $('#tpl-selected-assets').html() || ''
    @$templateSelectedUser = Hogan.compile $('#tpl-selected-user').html() || ''

  bindEvents: ->
    @setFocusToCode()
    if @checkCodeExists()
      $(document).on 'click', @$btnSend.selector, (e) => @checkAssetIfExists(e)
    $(document).on 'click', @$btnSave.selector, (e) => @saveSelectedAssets(e)

  displayAssetRows: (asset = null) ->
    @$containerTplSelectedAssets.html @$templateSelectedAssets.render(@assetsJSON())
    if asset
      $("#asset_#{asset.id}").hide().toggle('highlight')

  assetsJSON: ->
    assets: _assets.map (a, i) -> a.index = i + 1; a
    total: _assets.length

  checkAssetIfExists: (e) ->
    e.preventDefault()
    @changeToHyphens()
    code = @$code.val().trim()
    if code
      @searchInAssets(code, @displaySearchAsset)
    else
      @alert.info "Introduzca un Código de Activo"
    @$code.select()

  displayAssetRow: (data) ->

  displaySearchAsset: (code, data) =>
    if data
      if @displaySelectedUser(data.user)
        @displaySelectedAssets(data)
      else
        @alert.danger "El Usuario es distinto!<br/><b>#{data.user.name}</b><br/><em>#{data.user.title}</em>"
    else
      @alert.danger "El Código de Activo <b>#{code}</b> no se encuentra en la lista"

  displaySelectedAssets: (asset) ->
    index = @searchInLocalAssets(asset)
    if index >= 0
      @removeAssetRow(asset)
      _assets.splice(index, 1) # remove asset
      if _assets.length is 0 # reset _user var
        _user = null
        @showUserInfo()
    else
      _assets.unshift(asset)
      @displayAssetRows(asset)

  displaySelectedUser: (user) ->
    if @isUserSelected()
      return _user.id is user.id
    else
      _user = user
      @showUserInfo()
      return true

  isUserSelected: ->
    _user?

  removeAssetRow: (asset) ->
    $("#asset_#{asset.id}").hide 'slow', => @displayAssetRows()

  saveSelectedAssets: (e) ->
    e.preventDefault()
    json_data = { user_id: _user.id, asset_ids: (_assets.map (a) -> a.id), proceeding_type: 'D' }
    $.post @proceedings_url, { proceeding: json_data }, null, 'script'

  searchInAssets: (code, callback) ->
    $.ajax
      url: @assets_search_url
      type: 'GET'
      dataType: 'JSON'
      data: { user_id: (if _user then _user.id else null), code: code }
    .done (data) -> callback(code, data)

  searchInLocalAssets: (asset) ->
    index = -1
    for obj, i in _assets
      if obj.code is asset.code
        index = i
    return index

  showUserInfo: ->
    @$containerTplSelectedUser.html @$templateSelectedUser.render(_user)
