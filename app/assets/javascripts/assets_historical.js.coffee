$ -> new AssetsHistorical() if $('[data-action=historical-reviews]').length > 0

class AssetsHistorical
  constructor: ->
    @cacheElements()
    @bindEvents()

  cacheElements: ->
    # URLs
    @historical_url = '/assets/historical'
    @reviews_url = '/assets/reviews'
    # containers
    @$containerHistoricalReviews = $('.historical-reviews')
    @$containerLoader = $('.loading')
    # buttons
    @$radioOptionsHistorical = $('#options_historical')
    @$radioOptionsReviews = $('#options_reviews')
    # templates
    @$templateAssetsHistorical = Hogan.compile $('#tpl-assets-historical').html() || ''
    @$templateAssetsReviews = Hogan.compile $('#tpl-assets-reviews').html() || ''

  bindEvents: ->
    $(document).on 'change', @$radioOptionsHistorical.selector, (e) => @displayHistorical(e)
    $(document).on 'change', @$radioOptionsReviews.selector, (e) => @displayReviews(e)

  displayHistorical: (e) ->
    @$containerHistoricalReviews.hide()
    @$containerLoader.show()
    $.getJSON @historical_url, {asset_id: 49}, (data) =>
      console.log data
      @$containerHistoricalReviews.html @$templateAssetsHistorical.render(data)
      @$containerHistoricalReviews.show()
      @$containerLoader.hide()

  displayReviews: (e) ->
    @$containerHistoricalReviews.hide()
    @$containerLoader.show()
    $.getJSON @reviews_url, {asset_id: 49}, (data) =>
      @$containerHistoricalReviews.html @$templateAssetsReviews.render(data)
      @$containerHistoricalReviews.show()
      @$containerHistoricalReviews.show()
      @$containerLoader.hide()
    .fail (e) =>
      @$containerHistoricalReviews.show()
      @$containerLoader.hide()

