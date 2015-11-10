# Extractado de http://www.jacklmoore.com/notes/rounding-in-javascript/
round = (value, decimals) ->
  Number(Math.round(value+'e'+decimals)+'e-'+decimals)

total_cost = ($this) ->
  id = $this.parent().parent().parent().attr('id')
  amount = parseFloat($("input#amount_#{id}").val() || 0)
  unit_cost = parseFloat($("input#unit_cost_#{id}").val() || 0)
  cost_total = round(amount * unit_cost, 2)
  $("input#total_cost_#{id}").val(cost_total).parent().prev().text(cost_total.formatNumber(2, '.', ','))
  total = 0
  $("input.total_cost").map ->
    total += parseFloat($(this).val() || 0)
    $("#totalNoteEntry").text(total.formatNumber(2, '.', ','))
    $("input#note_entry_total").val(total)

style_date = (id)->
  $("<div class='input-group #{id} date'></div>").insertBefore("input##{id}")
  $("input##{id}").appendTo(".input-group.#{id}")
  $("<span class='input-group-addon glyphicon glyphicon-calendar'></span>").insertAfter("input##{id}")

date_picker = (year = false) ->
  if $(".edit_note_entry").length
    days = $("#get_date").data('date')
    date = "-#{days}d"
  else
    date = if year then (new Date((new Date).getFullYear(), 0, 1)) else ""
  $(".date").datepicker
    format: "dd/mm/yyyy"
    language: "es"
    startDate: date
    endDate: "+0d"

validation_decline = ($form, id) ->
  input = $("##{id}")
  if input.val() == ''
    input.parents('.form-group').addClass('has-error')
    input.after('<span class="help-block">es obligatorio</span>') unless input.next().length
    false
  else
    input.parents('.form-group').removeClass('has-error')
    input.next().remove()
    true

valid_entry = (condition, $input, date = false) ->
  input = if date then $input.parent() else $input
  if condition
    input.parent().parent().removeClass('has-error')
    input.next().remove() if input.next().length
    true
  else
    input.parent().parent().addClass('has-error')
    input.after('<span class="help-block">valor erróneo</span>') unless input.next().length
    false


jQuery ->
  TableTools.BUTTONS.download =
    sAction: "text"
    sTag: "default"
    sFieldBoundary: ""
    sFieldSeperator: "\t"
    sNewLine: "<br>"
    sToolTip: ""
    sButtonClass: "DTTT_button_text"
    sButtonClassHover: "DTTT_button_text_hover"
    sButtonText: "Download"
    mColumns: "all"
    bHeader: true
    bFooter: true
    sDiv: ""
    fnMouseover: null
    fnMouseout: null
    fnClick: (nButton, oConfig) ->
      oParams = @s.dt.oApi._fnAjaxParameters(@s.dt)
      iframe = document.createElement("iframe")
      iframe.style.height = "0px"
      iframe.style.width = "0px"
      status = if $('.button_new span.controller_name').text() == 'requests' then "&status=#{window.location.search.substring(8)}" else ''
      iframe.src = oConfig.sUrl + "?" + $.param(oParams) + "&search_column=#{ $('#select_column').val() }" + status
      document.body.appendChild iframe
    fnSelect: null
    fnComplete: null
    fnInit: null

  $(".datatable").dataTable
    sPaginationType: "bootstrap"
    aaSorting: if /\/versions$/.test(window.location.pathname) then [[0, 'desc']] else [[0, 'asc']]
    bProcessing: false
    bServerSide: true
    bLengthChange: false
    iDisplayLength: 15
    aoColumnDefs: [
      { sClass: 'nowrap', bSortable: false, aTargets: [ -1 ] },
      { sClass: 'nowrap', aTargets: [ 0 ] }
    ]
    oLanguage:
      sUrl: $('#datatable-spanish').data('url')
    sDom: 'T<"clear">lfrtip',
    fnServerParams: (aoData) ->
      aoData.push
        name: "search_column"
        value: $('#select_column').val()
    fnInitComplete: ->
      $('.dataTables_filter input').attr('placeholder', 'Buscar...').addClass('form-control').attr('id', 'subarticle')
      $('.DTTT_container').css('margin-left', 0) unless $('.DTTT_container').parents('.main').find('.button_new .btn').length
      table = $.fn.dataTable.fnTables(true)
      if table.length > 0
        $(table).dataTable().fnAdjustColumnSizing()
      $input = $("#subarticle")
      $input.keyup ->
        if $input.val().indexOf("'") > -1
          value = $input.val().replace("'", '-')
          $input.val(value)
    oTableTools:
      aButtons: [
        { sExtends: "download", sButtonText: "CSV", sUrl: "#{ $('.button_new span.controller_name').text() }.csv" }
        { sExtends: "download", sButtonText: "PDF", sUrl: "#{ $('.button_new span.controller_name').text() }.pdf" }
      ]
    fnDrawCallback: (oSettings) ->
      $('#select_column').appendTo $('.dataTables_filter')


  #grid report subarticle
  $("#report_subarticle").parent().attr('class','col-md-offset-1 col-lg-offset-1 col-md-10 col-lg-10')

  #Dropdown
  $('.dropdown-toggle').dropdown()

  # Change button status
  $(document).on 'click', '.datatable .btn-warning, .datatable .btn-success', (evt) ->
    tpl = $('#destroy-modal').html()
    data = $(@).data()
    html = Hogan.compile(tpl).render(data)
    $('#confirm-modal').html(html)
    $("#modal-#{ $(@).data('dom-id') }").modal('toggle')
    style_date("date_0")
    date_picker(true)
    evt.preventDefault()

  $(document).on 'click', '.modal .change_status', ->
    $(this).parents('.modal').modal('hide')
    id = $(this).closest('.modal').attr('id').substr(6)
    $user = $("table [data-dom-id=#{id}]")
    if $user.find('span').attr('class').substr(20) == 'ok'
      img = 'remove'
      text_old = 'Activar'
      text = 'Desactivar'
      status_td = 'ACTIVO'
    else
      img = 'ok'
      text_old = 'Desactivar'
      text = 'Activar'
      status_td = 'INACTIVO'
    message = $user.data('confirm-message').replace(text_old, text)
    $user.data('confirm-message', message)
    $user.parent().prev().text(status_td)
    $user.empty().append("<span class='glyphicon glyphicon-#{img}'></span>")

  # Ajax loading
  $(document).on 'ajaxStart', (e, xhr, settings, exception) ->
    NProgress.start()
  $(document).on 'ajaxComplete', (e, xhr, settings, exception) ->
    NProgress.done()

  $('#announcements').bind 'close.bs.alert', ->
    $.ajax
      url: $('#announcements').data('url')
      dataType: 'json'
      type: 'POST'

  # Form decline
  $(document).on 'click', '.deregister', ->
    $form = $(this).parents('.modal-dialog').find('form')
    validation_decline($form, 'asset_reason_decline')
    if validation_decline($form, 'asset_description_decline') && validation_decline($form, 'asset_reason_decline')
      $.ajax
        url: $form.attr('action')
        type: "post"
        data: $form.serialize()
        complete: (data, xhr) ->
          window.location = window.location

  $(document).on 'click', '.download-assets', (e) ->
    e.preventDefault()
    window.location = $(@).data('url')

  #Version select
  $(document).on 'click', 'table.table input:checkbox', ->
    disabled = if $("table.table input:checked").length == 0 then true else false
    $("a.remove_version").attr("disabled", disabled)

  $('.remove_version').click (e) ->
    versions = $('table.table input:checkbox:checked')
    if versions.length > 0
      ids = versions.map(->
        $(this).val()
      ).get()
      $.ajax
        url: $('#versions-export').data('url')
        type: "post"
        data: { ids: ids }
        complete: (data, xhr) ->
          window.location = window.location
    e.preventDefault()

  #Img Entity
  changeImg = (evt) ->
    if window.FileReader
      i = 0
      while f = evt.target.files[i]
        reader = new FileReader()
        reader.onload = ((theFile) ->
          (e) ->
            img = $(evt.currentTarget).prev().find('img')
            img.attr "src", e.target.result
            img.attr "title", escape(theFile.name)
        )(f)
        reader.readAsDataURL f
        i++
    else
      alert "El API File no es soportado por éste navegador"

  $(".imgHeaderEntity").on "change", changeImg

  $(".imgFooterEntity").on "change", changeImg

  # Change single quotes to hyphen text inputs
  $(document).on 'keydown', '.single-quotes-to-hyphen', (e) ->
    if e.keyCode is 13
      $(e.target).val Utils.singleQuotesToHyphen($(e.target).val())
      Utils.nextFieldFocus $(e.target)
      return false

  # Entry Subarticle
  style_date("note_entry_delivery_note_date")
  style_date("note_entry_invoice_date")
  style_date("q_request_created_at_gteq")
  style_date("q_request_created_at_lteq")

  # Formato de fecha en la creación de nueva solicitud
  style_date("date")

  date_picker()

  $(document).on 'keyup', 'input.amount', ->
    total_cost($(this))

  $(document).on 'keyup', 'input.unit_cost', ->
    total_cost($(this))

  $(document).on 'click', 'span.glyphicon-remove.pointer', ->
    $(this).parent().parent().remove()

  #resize tab
  $('a[data-toggle="tab"]').on 'shown.bs.tab', (e) ->
    $(window).resize()

  #new entry_subarticle
  $(document).on 'click', 'form .new_entry', (e) ->
    e.preventDefault()
    subarticle_id = $(this).parents('form').attr('id').substr(11)
    id = parseInt($(this).prev().attr('id')) + 1
    template = Hogan.compile $('#entry_subarticle').html()
    $(this).before template.render(subarticle_id: subarticle_id, id: id)
    style_date("date_#{id}")
    date_picker(true)

  $(document).on 'click', '.remove_entry', ->
    $(this).parent().prev().remove()
    $(this).parent().remove()

  $(document).on 'click', '#new_entry', ->
    valid = true
    $(".entry_subarticle").each (index) ->
      $amount = $(this).find('.amount')
      $unit_cost = $(this).find('.unit_cost')
      $date = $(this).find('.date input')
      valid_entry($.isNumeric($unit_cost.val()), $unit_cost)
      valid_entry($date.val()!='', $date, true)
      valid = valid_entry($.isNumeric($amount.val()), $amount) && valid_entry($.isNumeric($unit_cost.val()), $unit_cost) && valid_entry($date.val()!='', $date, true)
    if valid
      $new_entry = $('form.form_entry')
      $.post($new_entry.attr('action'), $new_entry.serialize()).done (params) ->
        id = $new_entry.attr('id').substr(11)
        $("a.btn-success[data-id='#{id}']").remove()
        $new_entry.parents('.modal').modal('hide')
