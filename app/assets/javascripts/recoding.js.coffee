$ -> new Recoding() if $('[data-action=recoding]').length > 0

class Recoding
  constructor: ->
    @cacheElements()
    @bindEvents()

  cacheElements: ->
    $form = $('form.recoding')
    # containers
    @$containerElementFound = $('#element-found')
    # inputs
    @$barcode = @$containerElementFound.find('[input=text]')
    @$codeName = $form.find('[input=text]')
    # buttons
    @$buttonSave = @$containerElementFound.find('button[type=submit]')
    @$buttonSearch = $form.find('button[type=submit]')

  bindEvents: ->
    $(document).on 'click', @$buttonSave.selector, (e) => @saveNewBarcode(e)

  saveNewBarcode: (e) ->
    e.preventDefault()
