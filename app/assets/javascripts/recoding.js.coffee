$ -> new Recoding() if $('[data-action=recoding]').length > 0

class Recoding
  _asset_id = null

  constructor: ->
    @cacheElements()
    @bindEvents()

  cacheElements: ->
    $form = $('form.recoding')
    # containers
    @$containerElementFound = $('#element-found')
    # inputs
    @$barcode = @$containerElementFound.find('input[type=text]')
    @$codeName = $form.find('input[type=text]')
    # buttons
    @$buttonSave = @$containerElementFound.find('button[type=submit]')
    @$buttonSearch = $form.find('button[type=submit]')
    # templates
    @$templateElementFound = Hogan.compile $('#tpl-element-found').html() || ''

  bindEvents: ->
    # typeahead for assets
    assetList = new Bloodhound(
      datumTokenizer: Bloodhound.tokenizers.obj.whitespace 'code'
      queryTokenizer: Bloodhound.tokenizers.whitespace
      remote: '/assets/autocomplete.json?q=%QUERY'
    )
    assetList.initialize()
    @$codeName.typeahead null,
      displayKey: 'code'
      source: assetList.ttAdapter()
      templates: @typeaheadTemplates()
    .on 'typeahead:selected', (evt, data) => @displaySelectedElement(data)
    .on 'typeahead:opened', (evt, data) => @resetSelectedElement(data)
    # click events
    $(document).on 'click', @$buttonSave.selector, (e) => @saveNewBarcode(e)
    @$codeName.focus()

  displaySelectedElement: (data) ->
    _asset_id = data.id
    @$containerElementFound.html @$templateElementFound.render(data)
    console.log _asset_id

  resetSelectedElement: (data) ->
    @$containerElementFound.html('')
    _asset_id = null

  saveNewBarcode: (e) ->
    e.preventDefault()

  typeaheadTemplates: ->
    empty: [
      '<p class="empty-message">',
      'No se encontró ningún elemento',
      '</p>'
    ].join('\n')
    suggestion: (data) ->
      Hogan.compile('<p><strong>{{code}}</strong> - <em>{{description}}</em></p>').render(data)
