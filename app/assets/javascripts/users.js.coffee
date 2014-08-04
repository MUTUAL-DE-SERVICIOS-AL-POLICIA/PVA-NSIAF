$ -> new UserAssets() if $('[data-action=historical-current]').length > 0

class UserAssets
  _historicalShowed = false

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
    # templates
    @$templateHistoricalAssets = Hogan.compile $('#tpl-historical-assets').html() || ''

  bindEvents: ->
    $(document).on 'change', @$radioReportsCurrent.selector, (e) => @displayCurrentAssets(e)
    $(document).on 'change', @$radioReportsHistorical.selector, (e) => @displayHistorical(e)

  displayCurrentAssets: (e) ->
    @$containerCurrentAssets.show()
    @$containerHistorical.hide()

  displayHistorical: (e) ->
    @$containerCurrentAssets.hide()
    unless @isHistoricalShowed()
      $.getJSON @$radioReportsHistorical.data('url'), (data) =>
        data['assets?'] = data.assets.length > 0
        @$containerHistorical.html @$templateHistoricalAssets.render(data)
        _historicalShowed = true
      .fail (e) =>
        data['assets?'] = data.assets.length > 0
        @$containerHistorical.html @$templateHistoricalAssets.render(data)
    @$containerHistorical.show()

  isHistoricalShowed: ->
    _historicalShowed is true
