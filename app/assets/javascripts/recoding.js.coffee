$ -> new Recoding() if $('[data-action=recoding]').length > 0

class Recoding
  _asset_id = null
  _barcode = ''

  constructor: ->
    @cacheElements()
    @bindEvents()

  cacheElements: ->
    $form = $('form.recoding')
    # urls
    @update_asset_url = '/assets/{id}'
    # containers
    @$containerElementFound = $('#element-found')
    # inputs
    @$barcode = @$containerElementFound.find('input[type=text]')
    @$codeName = $form.find('input[type=text]')
    # buttons
    @$buttonCancel = @$containerElementFound.find('button[type=reset]')
    @$buttonSave = @$containerElementFound.find('button[type=submit]')
    @$buttonSearch = $form.find('button[type=submit]')
    # templates
    @$templateElementFound = Hogan.compile $('#tpl-element-found').html() || ''
    # Growl Notices
    @alert = new Notices({ele: 'div.main'})

  bindEvents: ->
    # typeahead for assets
    @assetList = new Bloodhound(
      datumTokenizer: Bloodhound.tokenizers.obj.whitespace 'code'
      queryTokenizer: Bloodhound.tokenizers.whitespace
      remote: '/assets/autocomplete.json?q=%QUERY'
    )
    @assetList.initialize()
    @$codeName.typeahead
      hint: false
    ,
      displayKey: 'code'
      source: @assetList.ttAdapter()
      templates: @typeaheadTemplates()
    .on 'typeahead:selected', (evt, data) => @displaySelectedElement(data)
    # events
    $(document).on 'change', @$barcode.selector, (e) => @setBarcodeValue(e)
    $(document).on 'keydown', @$barcode.selector, (e) => @handleEscKey(e)
    $(document).on 'click', @$buttonCancel.selector, (e) => @resetSelectedElement(e)
    $(document).on 'click', @$buttonSave.selector, (e) => @saveNewBarcode(e)
    $(document).on 'keydown', @$codeName.selector, (e) => @preventEnterSubmit(e)
    @$codeName.focus()

  displaySelectedElement: (data) ->
    _asset_id = data.id
    @$containerElementFound.html @$templateElementFound.render(data)
    @$containerElementFound.show()
    @$containerElementFound.find('input[type=text]').focus()

  getBarcode: ->
    _barcode.toString().trim()

  handleEscKey: (e) ->
    if e.keyCode is 27
      @resetSelectedElement()

  preventEnterSubmit: (e) ->
    if e.keyCode is 13
      unless @$codeName.val().toString().trim()
        @alert.info "Introduzca Código o Nombre"
      e.preventDefault()
      return false

  resetSelectedElement: (e = null) ->
    e.preventDefault() if e
    _asset_id = null
    _barcode = ''
    @$containerElementFound.hide()
    @$codeName.focus()

  saveNewBarcode: (e) ->
    url = @update_asset_url.replace(/{id}/g, _asset_id)
    data = {asset: {barcode: @getBarcode()}}
    if data.asset.barcode
      @$buttonSave.prop('disabled', true)
      $.ajax {url: url, data: data, type: 'PUT', dataType: 'JSON'}
      .done (data) =>
        @alert.success "<b>OK</b> Se actualizó correctamente el Activo Fijo"
        @resetSelectedElement()
        @assetList.clearRemoteCache()
      .fail (data) =>
        @alert.danger "<b>Error</b> No se pudo guardar, puede ser que el código de barras no exista"
      .always =>
        @$buttonSave.prop('disabled', false)
    else
      @alert.info "Por favor introduzca un Código de Barras"
    e.preventDefault()

  setBarcodeValue: (e) ->
    _barcode = $(e.target).val()

  typeaheadTemplates: ->
    empty: [
      '<p class="empty-message">',
      'No se encontró ningún elemento',
      '</p>'
    ].join('\n')
    suggestion: (data) ->
      Hogan.compile('<p><strong>{{code}}</strong> - <em>{{description}}</em></p>').render(data)
