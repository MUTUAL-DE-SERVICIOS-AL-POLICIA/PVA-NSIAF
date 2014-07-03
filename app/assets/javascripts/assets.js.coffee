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
    @glyphiconUnchecked= '<span class="text-muted glyphicon glyphicon-unchecked"></span>'
    # containers
    @$selectUserAssets = $('#select-user-assets')
    @$selectUser = $('#select-user')
    @$container = $('#assig_devol')
    @$displayUserAssets = $('#display-user-assets')
    @$request = $('#request')
    # forms & inputs
    @$building = $('#building')
    @$department = $('#department')
    @$user = $('#user')
    # buttons
    @$btnAssignation = $('#btn_assignation')
    @$btnDevolution = $('#btn_devolution')
    @$btnCancel = $('#btn_cancel')
    @$btnEditRequest = $('#btn_edit_request')
    @$btnShowRequest = $('#btn-show-request')
    @$btnSaveRequest = $('#btn_save_request')
    @$btnCancelRequest = $('#btn_cancel_request')
    # Hogan templates
    @$templateAssigDevol = Hogan.compile $('#tpl_assig_devol').html() || ''
    @$templateFixedAssets = Hogan.compile $('#tpl-fixed-assets').html() || ''
    @$templateRequestButtons = Hogan.compile $('#request_buttons').html() || ''
    @$templateRequestAccept = Hogan.compile $('#request_accept').html() || ''
    @$templateRequestInput = Hogan.compile $('#request_input').html() || ''
    # urls
    @not_assigned_url = '/assets/not_assigned'
    @assigned_url = '/assets/assigned'
    @display_assets_url = '/assets/assign'
    @deallocate_assets_url = '/assets/deallocate'
    @proceedings_url = '/proceedings'
    @request_save_url = '/requests/'
    # Hogan template elements
    @cacheElementsTpl()

  cacheElementsTpl: ->
    @$btnCancelAssig = $('#btn_cancel_assig')
    @$btnContinue = $('#btn_continue')
    @$btnAccept = $('#btn_accept')
    @$btnCancel_ = $('#btn_cancel_')
    @$btnSend = $('#btn-send')
    @$code = $('#code')

  bindEvents: ->
    if @$building?
      @$department.remoteChained(@$building.selector, '/assets/departments.json')
      @$user.remoteChained(@$department.selector, '/assets/users.json')
    $(document).on 'click', @$btnAssignation.selector, (e) => @displayContainer(e, 'E', @not_assigned_url)
    $(document).on 'click', @$btnDevolution.selector, (e) => @displayContainer(e, 'D', @assigned_url)
    $(document).on 'click', @$btnCancel.selector, (e) => @redirectToAssets(e, @proceedings_url)
    $(document).on 'click', @$btnCancelAssig.selector, (e) => @hideContainer(e)
    $(document).on 'click', @$btnContinue.selector, (e) => @sendAssignation(e)
    $(document).on 'click', @$btnCancel_.selector, (e) => @displaySelectUserAsset(e)
    $(document).on 'click', @$btnAccept.selector, (e) => @generatePDF(e)
    $(document).on 'click', @$btnSend.selector, (e) => @checkAssetIfExists(e, false)
    $(document).on 'click', @$btnShowRequest.selector, => @show_request()
    $(document).on 'click', @$btnEditRequest.selector, => @edit_request()
    $(document).on 'click', @$btnSaveRequest.selector, => @save_request()
    $(document).on 'click', @$btnCancelRequest.selector, => @cancel_request()

  displayContainer: (e, proceeding_type, url) ->
    e.preventDefault()
    if @checkSelectedUser()
      @proceeding_type = proceeding_type # E = Entrega, D = Devolución
      @$selectUser.hide()
      @displayAllAssets(url)
    else
      alert('Seleccione Edificio, Departamento, y Usuario')

  hideContainer: (e) ->
    e.preventDefault()
    @$container.html('').hide()
    @$selectUser.show()
    @$btnCancel.get(0).focus()

  changeToHyphens: ->
    value = @$code.val().toString().trim()
    @$code.val value.replace(/\'/g, '-')

  checkSelectedUser: ->
    @$building.val() && @$department.val() && @$user.val()

  sendAssignation: (e) ->
    e.preventDefault()
    assets_ = @$container.find('form.selected-assets input[type=hidden]').filter(-> @.value != '').serialize()
    if @isAssignation()
      url = @display_assets_url
      message = 'Debe asignar al menos un activo'
    else
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
    @$code.slideDown -> @.focus()

  generatePDF: (e) ->
    e.preventDefault()
    json_data = { user_id: @$user.val(), asset_ids: @assetIds, proceeding_type: @proceeding_type }
    $.post @proceedings_url, { proceeding: json_data }, null, 'script'

  checkAssetIfExists: (e, request) ->
    e.preventDefault()
    @changeToHyphens()
    code = @$code.val().trim()
    if request
      title = 'Sub Atículo'
      inactive = "o se encuentra en estado inactivo"
    else
      title = 'Activo'
      inactive = ""
    if code
      asset_id = if request then @verifyCodeMaterial(code) else @searchInAssets(code)
      if asset_id
        if request then @addMaterial(asset_id) else @selectDeselectAssetRow(asset_id)
      else
        alert "El código de #{title} '#{code}' no se encuentra en la lista #{inactive}"
    else
      alert "Introduzca un código de #{title}"
    @$code.select()

  searchInAssets: (code) ->
    asset_id = 0
    $.each @assets, (key, obj) ->
      asset_id = obj.id if obj.code is code
    return asset_id

  selectDeselectAssetRow: (asset_id) ->
    $input = $("#asset_#{asset_id}")
    if $input.hasClass('info')
      $input.removeClass('info')
      $input.find('td:last-child').html(@glyphiconUnchecked)
      $input.find('td:first-child input[type=hidden]').val(null)
    else
      $input.addClass('info')
      $input.find('td:last-child').html(@glyphiconOk)
      $input.find('td:first-child input[type=hidden]').val(asset_id)

  renderSelectedAssets: (data) ->
    @assetIds = $.map(data.assets, (val, i) -> val.id)
    @$selectUserAssets.hide()
    @$displayUserAssets.html @$templateFixedAssets.render(data)
    @$displayUserAssets.show()
    @cacheElementsTpl()
    @$btnCancel_.get(0).focus()

  displayAllAssets: (url)->
    user_data = { user_id: @$user.val() }
    $.getJSON url, user_data, (data) => @renderTemplate(data)

  renderTemplate: (data) ->
    @assets = data.assets
    @$container.html @$templateAssigDevol.render(data)
    @$container.show()
    @cacheElementsTpl()
    @$code.slideDown -> @.focus()

  redirectToAssets: (e, url) ->
    e.preventDefault()
    window.location = url

  isAssignation: ->
    @proceeding_type is 'E'

  #Request
  show_request: ->
    table = @$request.find('table').clone()
    table.find('.col-md-2').each ->
      val = $(this).find(':input').val()
      val = if val then val else 0
      $(this).html val
    @$request.find('#table_request').hide()
    @$request.find('#materials').append table
    @$request.find('#materials').append @$templateRequestButtons.render()

  edit_request: ->
    $( ".page-header button:contains('Editar cantidad')" ).remove()
    $( ".page-header button:contains('Entregar producto')" ).remove()
    if @$request.find("table th:contains('Cantidad a entregar')").length
      @$request.find('#table_request td.col-md-2').each ->
        $(this).html "<input class='form-control input-sm' type='text' value=#{$(this).text()}>"
    else
      @$request.find('table thead tr').append '<th>Cantidad a entregar</th>'
      @$request.find('table tbody tr').append @$templateRequestInput.render()
    @$request.find('#table_request').append @$templateRequestAccept.render()

  save_request: ->
    materials = $.map($('#request #materials tbody tr'), (val, i) ->
      id: val.id
      amount_delivered: $(val).find('td.col-md-2').text()
    )
    data = { status: 'pending', subarticle_requests_attributes: materials }
    id = @$request.prev().find('h2 span').text()
    $.ajax
      type: "PUT"
      url: @request_save_url + id
      data: { request: data }
      complete: (data, xhr) ->
        window.location = window.location

  cancel_request: ->
    @$request.find('#table_request').show()
    @$request.find('#materials').empty()
