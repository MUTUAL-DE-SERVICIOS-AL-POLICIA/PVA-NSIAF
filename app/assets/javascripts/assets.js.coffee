jQuery ->
  app = new AssetEvents()

class AssetEvents
  constructor: ->
    @cacheElements()
    @bindEvents()

  cacheElements: ->
    # variables
    @assets = []
    @assetIds = []
    @proceeding_type = null
    @glyphiconOk= '<span class="glyphicon glyphicon-ok"></span>'
    # containers
    @$selectUserAssets = $('#select-user-assets')
    @$selectUser = $('#select-user')
    @$container = $('#assig_devol')
    @$displayUserAssets = $('#display-user-assets')
    # forms & inputs
    @$frmSelectUser = @$selectUser.find('form')
    @$building = $('#building')
    @$department = $('#department')
    @$user = $('#user')
    # buttons
    @$btnAssignation = $('#btn_assignation')
    @$btnDevolution = $('#btn_devolution')
    @$btnCancel = $('#btn_cancel')
    # Hogan templates
    @$templateAssigDevol = Hogan.compile $('#tpl_assig_devol').html() || ''
    @$templateFixedAssets = Hogan.compile $('#tpl-fixed-assets').html() || ''
    # urls
    @not_assigned_url = '/assets/not_assigned'
    @assigned_url = '/assets/assigned'
    @display_assets_url = '/assets/assign'
    @deallocate_assets_url = '/assets/deallocate'
    @proceedings_url = '/proceedings'

  cacheElementsTpl: ->
    @$btnCancelAssig = $('#btn_cancel_assig')
    @$btnContinue = $('#btn_continue')
    @$btnAccept = $('#btn_accept')
    @$btnCancel_ = $('#btn_cancel_')
    @$btnSend = $('#btn-send')
    @$chkSelectedAssets = $('input[type=checkbox].selected-assets')
    @$code = $('#code')

  bindEventsTpl: ->
    @$btnCancelAssig.on 'click', (e) => @hideContainer(e)
    @$btnContinue.on 'click', (e) => @sendAssignation(e)
    @$btnCancel_.on 'click', (e) => @displaySelectUserAsset(e)
    @$btnAccept.on 'click', (e) => @generatePDF(e)
    @$btnSend.on 'click', (e) => @checkAssetIfExists(e)

  bindEvents: ->
    @$department.remoteChained('#building', '/assets/departments.json')
    @$user.remoteChained('#department', '/assets/users.json')
    @$btnAssignation.on 'click', (e) => @displayContainer(e, 'E', @not_assigned_url)
    @$btnDevolution.on 'click', (e) => @displayContainer(e, 'D', @assigned_url)
    @$btnCancel.on 'click', (e) => @redirectToAssets(e)

  displayContainer: (e, proceeding_type, url) ->
    e.preventDefault()
    if @checkSelectedUser()
      @proceeding_type = proceeding_type # E = Entrega, D = Devolución
      @disableForm()
      @displayAllAssets(url)
    else
      alert('Seleccione Edificio, Departamento, y Usuario')

  hideContainer: (e) ->
    e.preventDefault()
    @$container.html('').hide()
    @enableForm()
    @$btnCancel.get(0).focus()

  checkSelectedUser: ->
    @$building.val() && @$department.val() && @$user.val()

  disableForm: ->
    @$frmSelectUser.find(':input').prop('disabled', true)
    @$selectUser.hide()

  enableForm: ->
    @$frmSelectUser.find(':input').prop('disabled', false)
    @$selectUser.show()

  sendAssignation: (e) ->
    e.preventDefault()
    if @isAssignation()
      assets_ = @$chkSelectedAssets.closest('form.selected-assets').serialize()
      url = @display_assets_url
      message = 'Debe asignar al menos un activo'
    else
      assets_ = @$container.find('form.selected-assets input[type=hidden]').filter(-> @.value != '').serialize()
      url = @deallocate_assets_url
      message = 'Seleccione al menos un activo para devolver'
    if assets_
      assets_ = assets_ + '&user_id=' + @$user.val()
      $.getJSON url, assets_, (data) => @renderSelectedAssets(data)
    else
      alert message


  displaySelectUserAsset: (e) ->
    e.preventDefault()
    @$displayUserAssets.hide()
    @$selectUserAssets.show()
    if @isAssignation()
      @$btnCancelAssig.get(0).focus()
    else
      @$code.slideDown -> @.focus()

  generatePDF: (e) ->
    e.preventDefault()
    json_data = { user_id: @$user.val(), asset_ids: @assetIds, proceeding_type: @proceeding_type }
    $.post @proceedings_url, { proceeding: json_data }, null, 'script'

  checkAssetIfExists: (e) ->
    e.preventDefault()
    code = @$code.val().trim()
    if code
      if (asset_id = @searchInAssets(code)) > 0
        @selectAssetRow(asset_id)
      else
        alert "El código de Activo '#{code}' no se encuentra en la lista"
    else
      alert 'Introduzca un código de Activo'
    @$code.select()

  searchInAssets: (code) ->
    asset_id = 0
    $.each @assets, (key, obj) ->
      asset_id = obj.id if obj.code is code
    return asset_id

  selectAssetRow: (asset_id) ->
    $input = $("#asset_#{asset_id}")
    $input.addClass('info')
    $input.find('td:last-child').html(@glyphiconOk)
    $input.find('td:first-child input[type=hidden]').val(asset_id)

  renderSelectedAssets: (data) ->
    @assetIds = $.map(data.assets, (val, i) -> val.id)
    @$selectUserAssets.hide()
    @$displayUserAssets.html @$templateFixedAssets.render(data)
    @$displayUserAssets.show()
    @cacheElementsTpl()
    @bindEventsTpl()
    @$btnCancel_.get(0).focus()

  displayAllAssets: (url)->
    user_data = { user_id: @$user.val() }
    $.getJSON url, user_data, (data) => @renderTemplate(data)

  renderTemplate: (data) ->
    @assets = data.assets
    @$container.html @$templateAssigDevol.render(data)
    @$container.show()
    @cacheElementsTpl()
    @bindEventsTpl()
    if @isAssignation()
      @$container.find('form.selected-assets td:first input[type=checkbox]').focus()


  redirectToAssets: (e) ->
    e.preventDefault()
    window.location = @proceedings_url

  isAssignation: ->
    @proceeding_type is 'E'
