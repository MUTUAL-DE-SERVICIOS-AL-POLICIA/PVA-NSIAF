jQuery ->
  app = new AssetEvents()

class AssetEvents
  constructor: ->
    @cacheElements()
    @bindEvents()

  cacheElements: ->
    # variables
    @assetIds = []
    @proceeding_type = null
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
    @display_assets_url = '/assets/assign'
    @proceedings_url = '/proceedings'
    @assets_url = '/assets'

  cacheElementsTpl: ->
    @$btnCancelAssig = $('#btn_cancel_assig')
    @$btnContinue = $('#btn_continue')
    @$btnAccept = $('#btn_accept')
    @$btnCancel_ = $('#btn_cancel_')
    @$chkSelectedAssets = $('input[type=checkbox].selected-assets')

  bindEventsTpl: ->
    @$btnCancelAssig.on 'click', (e) => @hideContainer(e)
    @$btnContinue.on 'click', (e) => @sendAssignation(e)
    @$btnCancel_.on 'click', (e) => @displaySelectUserAsset(e)
    @$btnAccept.on 'click', (e) => @generatePDF(e)

  bindEvents: ->
    @$department.remoteChained('#building', '/assets/departments.json')
    @$user.remoteChained('#department', '/assets/users.json')
    @$btnAssignation.on 'click', (e) => @displayContainer(e)
    @$btnDevolution.on 'click', (e) => @displayDevolution(e)
    @$btnCancel.on 'click', (e) => @redirectToAssets(e)

  displayContainer: (e) ->
    e.preventDefault()
    if @checkSelectedUser()
      @proceeding_type = 'E' # Entrega
      @disableForm()
      @displayAllAssets()
      @$container.show()
    else
      alert('Seleccione Edificio, Departamento, y Usuario')

  displayDevolution: (e) ->
    e.preventDefault()
    if @checkSelectedUser()
      @proceeding_type = 'D' # Devolución
      #@disableForm()
      @displayAssignedAssets()
      @$container.show()
    else
      alert('Seleccione Edificio, Departamento, y Usuario')

  hideContainer: (e) ->
    e.preventDefault()
    @$container.hide()
    @enableForm()

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
    assets_ = @$chkSelectedAssets.closest('form').serialize()
    if assets_
      assets_ = assets_ + '&user_id=' + @$user.val()
      $.getJSON @display_assets_url, assets_, (data) => @renderSelectedAssets(data)
    else
      alert 'Debe asignar al menos un activo'

  displaySelectUserAsset: (e) ->
    e.preventDefault()
    @$displayUserAssets.hide()
    @$selectUserAssets.show()

  generatePDF: (e) ->
    e.preventDefault()
    json_data = { user_id: @$user.val(), asset_ids: @assetIds, proceeding_type: @proceeding_type }
    $.post @proceedings_url, { proceeding: json_data }, null, 'script'

  renderSelectedAssets: (data) ->
    @assetIds = $.map(data.assets, (val, i) -> val.id)
    @$selectUserAssets.hide()
    @$displayUserAssets.html @$templateFixedAssets.render(data)
    @$displayUserAssets.show()
    @cacheElementsTpl()
    @bindEventsTpl()

  displayAllAssets: ->
    user_data = { user_id: @$user.val() }
    $.getJSON @not_assigned_url, user_data, (data) => @renderTemplate(data)

  displayAssignedAssets: ->
    alert 'Mostrando Activos del usuario :P'
    # TODO mostrar los Activos asignados al usuario, y el formulario para
    # realizar la devolución

  renderTemplate: (data) ->
    @$container.html @$templateAssigDevol.render(data)
    @cacheElementsTpl()
    @bindEventsTpl()

  redirectToAssets: (e) ->
    e.preventDefault()
    window.location = @assets_url
