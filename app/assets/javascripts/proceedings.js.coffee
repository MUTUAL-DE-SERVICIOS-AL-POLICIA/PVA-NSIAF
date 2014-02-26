jQuery ->
  proceeding = new DisplayProceeding()

class DisplayProceeding
  constructor: ->
    @cacheElements()
    @displayProceeding()

  cacheElements: ->
    @$proceedingDelivery = $('#proceeding-delivery')
    @tplProceedingDelivery = Hogan.compile $('#tpl-proceeding-delivery').html() || ''

  displayProceeding: ->
    data = @$proceedingDelivery.data()
    @$proceedingDelivery.html @tplProceedingDelivery.render(data)
