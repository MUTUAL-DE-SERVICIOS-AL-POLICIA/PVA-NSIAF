root = exports ? this

class BarcodeReader
  constructor: ->
    @cacheElements()
    @bindEvents()

  cacheElements: ->
    # buttons
    @$btnSend = $('#btn-send')
    # textfields
    @$code = $('#code')

  bindEvents: ->
    @setFocusToCode()

  changeToHyphens: ->
    if @checkCodeExists()
      value = @$code.val().toString().trim()
      @$code.val value.replace(/\'/g, '-')

  checkCodeExists: ->
    @$code && @$code.length > 0

  # Set focus to code textfield every 5 seconds
  setFocusToCode: ->
    setFocus = =>
      @$code.focus() if @checkCodeExists()
    setInterval(setFocus, 5000)

root.BarcodeReader = BarcodeReader
