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
      @$code.val Utils.singleQuotesToHyphen(@$code.val())

  checkCodeExists: ->
    @$code && @$code.length > 0

  # Set focus to code textfield every 5 seconds
  setFocusToCode: ->
    setFocus = =>
      @$code.focus() if @checkCodeExists()
    setInterval(setFocus, 5000)

root.BarcodeReader = BarcodeReader
