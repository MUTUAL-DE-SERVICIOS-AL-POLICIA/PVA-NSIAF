$ -> new Assignations()

class Assignations extends BarcodeReader
  _assets = []
  _proceeding_type = null
  _user = null

  constructor: ->
    @cacheElements()
    @bindEvents()

  cacheElements: ->
    # URLs
    @admin_assets_search_url = '/assets/admin_assets'
    @proceedings_url = '/proceedings'
    @user_url = '/users/{id}.json'
    # Containers
    @$containerTplSelectedAssets = $('#container-tpl-selected-assets[data-action=assignation]')
    @$containerTplSelectedUser = $('#container-tpl-selected-user')
    @$containerSelectUser = $('#container-select-user')
    # forms & inputs
    @$building = $('#building')
    @$department = $('#department')
    @$user = $('#user')
    # buttons
    @$btnAssignation = $('#btn_assignation')
    @$btnCancel = @$containerTplSelectedAssets.find('button[data-type=cancel]')
    @$btnReturn = $('#btn_cancel')
    @$btnSave = @$containerTplSelectedAssets.find('button[data-type=save]')
    # Growl Notices
    @alert = new Notices({ele: 'div.main'})
    # Hogan templates
    @$templateSelectedAssets = Hogan.compile $('#tpl-selected-assets').html() || ''
    @$templateSelectedUser = Hogan.compile $('#tpl-selected-user').html() || ''
    @cacheTplElements()

  cacheTplElements: ->
    $form = $('form[data-action=assignation]')
    @$code = $form.find('input[type=text]')
    @$btnSend = $form.find('button[type=submit]')
    if @checkCodeExists()
      $(document).on 'click', @$btnSend.selector, (e) => @checkAssetIfExists(e)

  bindEvents: ->
    @setFocusToCode()
    if @$building?
      @$department.remoteChained(@$building.selector, '/assets/departments.json')
      @$user.remoteChained(@$department.selector, '/assets/users.json')
    $(document).on 'click', @$btnAssignation.selector, (e) => @displayContainer(e, 'E', @not_assigned_url)
    $(document).on 'click', @$btnCancel.selector, (e) => @resetDevolutionViews(e)
    $(document).on 'click', @$btnReturn.selector, (e) => @redirectToAssets(e, @proceedings_url)
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

  checkSelectedUser: ->
    @$building.val() && @$department.val() && @$user.val()

  displayContainer: (e, proceeding_type, url) ->
    e.preventDefault()
    if @checkSelectedUser()
      _proceeding_type = proceeding_type # E = Entrega, D = Devolución
      @$containerSelectUser.hide()
      @showUserInfo()
      @displayAssetRows()
    else
      @alert.info 'Seleccione <b>Edificio</b>, <b>Departamento</b>, y <b>Usuario</b>'

  displaySearchAsset: (code, data) =>
    if data
      @displaySelectedAssets(data)
    else
      @alert.danger "El Código de Activo <b>#{code}</b> ya está asignado o no existe"

  displaySelectedAssets: (asset) ->
    index = @searchInLocalAssets(asset)
    if index >= 0
      @removeAssetRow(asset)
      _assets.splice(index, 1) # remove asset
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

  redirectToAssets: (e, url) ->
    e.preventDefault()
    window.location = url

  removeAssetRow: (asset) ->
    $("#asset_#{asset.id}").hide 'slow', => @displayAssetRows()

  resetDevolutionViews: (e) ->
    _assets = []
    _user = null
    @$containerTplSelectedUser.html('')
    @$containerTplSelectedAssets.html('')
    @$containerSelectUser.show()

  saveSelectedAssets: (e) ->
    e.preventDefault()
    if _assets.length > 0
      # TODO falta que guarde para asignación de activos
      #
      #
      #
      #
      #
      json_data = { user_id: _user.id, asset_ids: (_assets.map (a) -> a.id), proceeding_type: 'D' }
      $.post @proceedings_url, { proceeding: json_data }, null, 'script'
    else
      @alert.danger 'Debe seleccionar al menos un Activo'

  searchInAssets: (code, callback) ->
    $.getJSON @admin_assets_search_url, {code: code}, (data) ->
      callback(code, data)

  searchInLocalAssets: (asset) ->
    index = -1
    for obj, i in _assets
      if obj.code is asset.code
        index = i
    return index

  showUserInfo: ->
    $.getJSON @user_url.replace(/{id}/g, @$user.val()), (data) =>
      _user = data
      @$containerTplSelectedUser.html @$templateSelectedUser.render(_user)
      @cacheTplElements()
      @$code.select()
