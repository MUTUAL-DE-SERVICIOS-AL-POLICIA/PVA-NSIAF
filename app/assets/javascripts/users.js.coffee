$ -> new UserAssets() if $('[data-action=historical-current]').length > 0

class UserAssets
  constructor: ->
    @cacheElements()
    @bindEvents()

  cacheElements: ->
    # buttons
    @$radioReportsCurrent = $('#reports_current')
    @$radioReportsHistorical = $('#reports_historical')
    # containers
    @$containerCurrentAssets = $('#current-assets')
    @$containerHistorical = $('#historical')

  bindEvents: ->
    $(document).on 'change', @$radioReportsCurrent.selector, (e) => @displayCurrentAssets(e)
    $(document).on 'change', @$radioReportsHistorical.selector, (e) => @displayHistorical(e)

  displayCurrentAssets: (e) ->
    @$containerCurrentAssets.show()
    @$containerHistorical.hide()

  displayHistorical: (e) ->
    @$containerCurrentAssets.hide()
    @$containerHistorical.show()
