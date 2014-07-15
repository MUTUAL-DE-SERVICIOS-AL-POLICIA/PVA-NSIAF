$ -> new Devolutions() if $('[data-action=devolution]').length > 0

class Devolutions extends BarcodeReader
  _assets = []
  _proceeding_type = 'D'
  _user = null

  constructor: ->
    @cacheElements()
    @bindEvents()

  cacheElements: ->
    $form = $('form')
    # URLs
    @assets_search_url = '/assets/search'
    @proceedings_url = '/proceedings'
    # Containers
    @$containerTplSelectedAssets = $('#container-tpl-selected-assets')
    @$containerTplSelectedUser = $('#container-tpl-selected-user')
    # textfields
    @$code = $form.find('input[type=text]')
    # buttons
    @$btnCancel = @$containerTplSelectedAssets.find('button[data-type=cancel]')
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
    $(document).on 'click', @$btnCancel.selector, (e) => @resetDevolutionViews(e)

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

  displaySearchAsset: (code, data) =>
    if data
      if @displaySelectedUser(data.user)
        @displaySelectedAssets(data)
      else
        @alert.danger "El Activo con código <b>#{code}</b> pertenece a otro usuario: <br/><b>#{data.user.name}</b> (<em>#{data.user.title}</em>)"
    else
      @alert.danger "El Código de Activo <b>#{code}</b> no está asignado o no existe"

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

  resetDevolutionViews: (e) ->
    _assets = []
    _user = null
    @$containerTplSelectedUser.html('')
    @$containerTplSelectedAssets.html('')
    @$code.val('').select()

  saveSelectedAssets: (e) ->
    e.preventDefault()
    if _assets.length > 0
      json_data = { user_id: _user.id, asset_ids: (_assets.map (a) -> a.id), proceeding_type: _proceeding_type }
      $.post @proceedings_url, { proceeding: json_data }, null, 'script'
    else
      @alert.danger 'Debe seleccionar al menos un Activo'

  searchInAssets: (code, callback) ->
    $.ajax
      url: @assets_search_url
      type: 'GET'
      dataType: 'JSON'
      data: { code: code }
    .done (data) -> callback(code, data)

  searchInLocalAssets: (asset) ->
    index = -1
    for obj, i in _assets
      if obj.code is asset.code
        index = i
    return index

  showUserInfo: ->
    @$containerTplSelectedUser.html @$templateSelectedUser.render(_user)
