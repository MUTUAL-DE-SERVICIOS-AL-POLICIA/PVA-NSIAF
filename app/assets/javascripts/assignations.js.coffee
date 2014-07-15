$ -> new Assignations() if $('[data-action=assignation]').length > 0

class Assignations extends BarcodeReader
  _assets = []
  _proceeding_type = 'E'
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
    @$containerTplSelectedAssets = $('#container-tpl-selected-assets')
    @$containerTplSelectedUser = $('#container-tpl-selected-user')
    @$containerSelectUser = $('#container-select-user')
    @$containerTplProceedingDelivery = $('#proceeding-delivery')
    # forms & inputs
    @$building = $('#building')
    @$department = $('#department')
    @$user = $('#user')
    # buttons
    @$btnAssignation = $('#btn_assignation')
    @$btnBack = @$containerTplSelectedAssets.find('button[data-type=back]')
    @$btnCancel = @$containerTplProceedingDelivery.find('button[data-type=cancel]')
    @$btnNext = @$containerTplSelectedAssets.find('button[data-type=next]')
    @$btnReturn = $('#btn_cancel')
    @$btnSave = @$containerTplProceedingDelivery.find('button[data-type=save]')
    # Growl Notices
    @alert = new Notices({ele: 'div.main'})
    # Hogan templates
    @$templateProceedingDelivery = Hogan.compile $('#tpl-proceeding-delivery').html() || ''
    @$templateSelectedAssets = Hogan.compile $('#tpl-selected-assets').html() || ''
    @$templateSelectedUser = Hogan.compile $('#tpl-selected-user').html() || ''
    @cacheTplElements()

  cacheTplElements: ->
    $form = $('form[data-action=assignation]')
    @$code = $form.find('input[type=text]')
    @$btnSend = $form.find('button[type=submit]')

  bindEvents: ->
    @setFocusToCode()
    if @$building?
      @$department.remoteChained(@$building.selector, '/assets/departments.json')
      @$user.remoteChained(@$department.selector, '/assets/users.json')
    $(document).on 'click', @$btnAssignation.selector, (e) => @displayContainer(e)
    $(document).on 'click', @$btnBack.selector, (e) => @backToSelectUser(e)
    $(document).on 'click', @$btnCancel.selector, (e) => @backToSelectAssets(e)
    $(document).on 'click', @$btnNext.selector, (e) => @previewProceeding(e)
    $(document).on 'click', @$btnReturn.selector, (e) => @redirectToAssets(e, @proceedings_url)
    $(document).on 'click', @$btnSave.selector, (e) => @saveSelectedAssets(e)
    $(document).on 'click', @$btnSend.selector, (e) => @checkAssetIfExists(e)

  displayAssetRows: (asset = null) ->
    @$containerTplSelectedAssets.html @$templateSelectedAssets.render(@assetsJSON())
    @$containerTplSelectedAssets.show()
    if asset
      $("#asset_#{asset.id}").hide().toggle('highlight')

  assetsJSON: ->
    assets: _assets.map (a, i) -> a.index = i + 1; a
    total: _assets.length

  backToSelectUser: (e) ->
    e.preventDefault()
    @$containerSelectUser.show()
    @$containerTplSelectedAssets.hide()
    @$containerTplSelectedUser.hide()

  backToSelectAssets: (e) ->
    e.preventDefault()
    @$containerTplProceedingDelivery.hide()
    @$containerTplSelectedAssets.show()
    @$containerTplSelectedUser.show()
    @$code.focus()

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

  displayContainer: (e) ->
    e.preventDefault()
    if @checkSelectedUser()
      @$containerSelectUser.hide()
      @showUserInfo @$user.val()
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

  previewProceeding: (e) ->
    e.preventDefault()
    if _assets.length > 0
      assignation =
        assets: _assets
        devolution: false
        proceedingDate: moment().format('LL')
        userName: _user.name
        userTitle: _user.title
      @$containerTplProceedingDelivery.html @$templateProceedingDelivery.render(assignation)
      @$containerTplProceedingDelivery.show()
      @$containerTplSelectedAssets.hide()
      @$containerTplSelectedUser.hide()
    else
      @alert.danger 'Debe seleccionar al menos un Activo'

  redirectToAssets: (e, url) ->
    e.preventDefault()
    window.location = url

  removeAssetRow: (asset) ->
    $("#asset_#{asset.id}").hide 'slow', => @displayAssetRows()

  saveSelectedAssets: (e) ->
    e.preventDefault()
    if _assets.length > 0
      json_data = { user_id: _user.id, asset_ids: (_assets.map (a) -> a.id), proceeding_type: _proceeding_type }
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

  showUserInfo: (user_id) ->
    if _user && _user.id is parseInt(user_id)
      @$containerTplSelectedUser.show()
      @$code.select()
    else
      $.getJSON @user_url.replace(/{id}/g, @$user.val()), (data) =>
        _user = data
        @$containerTplSelectedUser.html @$templateSelectedUser.render(_user)
        @$containerTplSelectedUser.show()
        @cacheTplElements()
        @$code.select()
