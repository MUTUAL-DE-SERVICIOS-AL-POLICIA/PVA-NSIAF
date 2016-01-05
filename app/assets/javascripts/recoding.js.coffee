$ -> new Recoding() if $('[data-action=recoding]').length > 0

class Recoding extends BarcodeReader
  _asset_id = null
  _barcode = ''

  constructor: ->
    @cacheElements()
    @bindEvents()

  cacheElements: ->
    $form = $('form.recoding')
    @$recoding_urls = $('#recoding-urls')
    @is_assets = /\/assets\//.test(window.location.pathname)
    # urls
    @update_recode_url = decodeURIComponent @$recoding_urls.data('recode-id')
    @recode_autocomplete_url = decodeURIComponent @$recoding_urls.data('recode-autocomplete')
    unless @is_assets
      @update_recode_url = @update_recode_url.replace(/assets/, 'subarticles')
      @recode_autocomplete_url = @recode_autocomplete_url.replace(/assets/, 'subarticles')
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
      remote: @recode_autocomplete_url
    )
    @assetList.initialize()
    @$codeName.typeahead
      hint: false
    ,
      #displayKey: 'code'
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
    @setFocusBarcode()

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
    @$codeName.select()

  saveNewBarcode: (e) ->
    url = @update_recode_url.replace(/{id}/g, _asset_id)
    if @is_assets
      data = {asset: {barcode: @getBarcode()}}
      barcode = data.asset.barcode
    else
      data = {subarticle: {barcode: @getBarcode()}}
      barcode = data.subarticle.barcode
    if barcode
      @$buttonSave.prop('disabled', true)
      $.ajax {url: url, data: data, type: 'PUT', dataType: 'JSON'}
      .done (data) =>
        @alert.success "<b>OK</b> Se actualizó correctamente el Activo Fijo con el Código de Barras <b>#{@getBarcode()}</b>"
        @resetSelectedElement()
        @assetList.clearRemoteCache()
      .fail (data) =>
        @alert.danger "<b>Error</b> No se pudo guardar el Código de Barras <b>#{@getBarcode()}</b>, puede ser que no exista, ya esté en uso, o fue utilizado"
        @setFocusBarcode()
      .always =>
        @$buttonSave.prop('disabled', false)
    else
      @alert.info "Por favor introduzca un Código de Barras"
      @setFocusBarcode()
    e.preventDefault()

  setBarcodeValue: (e) ->
    $e = $(e.target)
    $e.val Utils.singleQuotesToHyphen($e.val())
    _barcode = $e.val()

  setFocusBarcode: ->
    @$containerElementFound.find('input[type=text]').select()
