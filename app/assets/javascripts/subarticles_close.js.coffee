$ -> new SubarticlesClose() if $('[data-action=subarticles-close]').length > 0

class SubarticlesClose
  _subarticle_ids = []
  _deactivate_all = true
  _year = null

  constructor: ->
    @cacheElements()
    @bindEvents()

  cacheElements: ->
    _year = $('[data-year]').data('year')
    @select_date = '#select_date'
    # buttons
    @$btn_close_subarticles = $('#btn-close-subarticles')
    @$subarticles_close = $('button.sa-close')
    # containers
    @$confirm_modal = $('#confirm-modal')
    @modal_id = '#modal-subarticle-close'
    # inputs
    @$checkbox_close = $('input.checkbox-close')
    @$checkbox_close_all = $('input.checkbox-close-all')
    # templates
    @$select_date_tpl = Hogan.compile $('#select-date-tpl').html() || ''
    # Growl Notices
    @alert = new Notices({ele: 'div.main'})

  bindEvents: ->
    $(document).on 'click', @$btn_close_subarticles.selector, (e) => @saveSubarticles(e)
    $(document).on 'click', @$subarticles_close.selector, (e) => @closeSubarticle(e)
    $(document).on 'change', @$checkbox_close.selector, (e) => @selectSubarticle(e)
    $(document).on 'change', @$checkbox_close_all.selector, (e) => @selectAllSubarticles(e)

  checkAllSelected: ->
    if _deactivate_all is true
      checked = @$checkbox_close.length is _subarticle_ids.length
      @$checkbox_close_all.prop 'checked', checked

  clearCheckboxes: ->
    @$checkbox_close_all.prop('checked', false)
    $.each @$checkbox_close, (i, e) ->
      $(e).prop('checked', false)
      $(e).trigger('change')

  closeSubarticle: ->
    data =
      title: 'Establecer fecha para los saldos iniciales de la siguiente gestión'
      domId: 'subarticle-close'
    @$confirm_modal.html @$select_date_tpl.render(data)
    @$confirm_modal.find(@modal_id).modal('show')
    @datepicker()

  datepicker: ->
    $(".date").datepicker
      autoclose: true
      format: "dd/mm/yyyy"
      language: "es"

  displayCloseButton: ->
    if _subarticle_ids.length > 0
      @$subarticles_close.show()
    else
      @$subarticles_close.hide()

  saveSubarticles: (e) ->
    data =
      subarticle_ids: _subarticle_ids
      year: _year
      date: $(@select_date).val()

    $.ajax
      dataType: 'json'
      type: 'POST'
      data: data
    .done (d) => @successfullySave()
    .fail (d) => @$confirm_modal.find(@modal_id).modal('hide')

  selectAllSubarticles: (e) ->
    _deactivate_all = false
    $.each @$checkbox_close, (i, c) ->
      $(c).prop('checked', $(e.target).is(':checked'))
      $(c).trigger('change')
    _deactivate_all = true

  selectSubarticle: (e) ->
    index = _subarticle_ids.indexOf $(e.target).val()
    if $(e.target).is(':checked')
      if index is -1
        _subarticle_ids.push $(e.target).val()
    else
      if index > -1
        _subarticle_ids.splice(index, 1)

    @displayCloseButton()
    @checkAllSelected()

  successfullySave: ->
    @$confirm_modal.find(@modal_id).modal('hide')
    @alert.info "Se actualizó correctamente los #{_subarticle_ids.length} subartículos."
    @clearCheckboxes()
