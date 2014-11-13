total_cost = ->
  amount = parseFloat($("input#entry_subarticle_amount").val() || 0)
  unit_cost = parseFloat($("input#entry_subarticle_unit_cost").val() || 0)
  $("input#entry_subarticle_total_cost").val(amount * unit_cost)

jQuery ->
  filter = if $("h2:contains('Histórico')").length then false else true
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
    bFilter: filter
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
      $('.dataTables_filter input').attr('placeholder', 'Buscar...').addClass('form-control')
      $('.DTTT_container').css('margin-left', 0) unless $('.DTTT_container').parents('.main').find('.button_new .btn').length
      table = $.fn.dataTable.fnTables(true)
      if table.length > 0
        $(table).dataTable().fnAdjustColumnSizing()
    oTableTools:
      aButtons: [
        { sExtends: "download", sButtonText: "CSV", sUrl: "#{ $('.button_new span.controller_name').text() }.csv" }
        { sExtends: "download", sButtonText: "PDF", sUrl: "#{ $('.button_new span.controller_name').text() }.pdf" }
      ]
    fnDrawCallback: (oSettings) ->
      $('#select_column').appendTo $('.dataTables_filter')

  #Dropdown
  $('.dropdown-toggle').dropdown()

  # Change button status
  $(document).on 'click', '.datatable .btn-warning', (evt) ->
    tpl = $('#destroy-modal').html()
    data = $(@).data()
    html = Hogan.compile(tpl).render(data)
    $('#confirm-modal').html(html)
    $("#modal-#{ $(@).data('dom-id') }").modal('toggle')
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
    if $form.find('#description').val() != '' && $form.find('#reason').val() != ''
      $.ajax
        url: $form.attr('action')
        type: "post"
        data: $form.serialize()
        complete: (data, xhr) ->
          window.location = window.location
    else
      $div = $(this).parent().prev().find('.form-group')
      $div.addClass('has-error')
      $div.find('textarea').after('<span class="help-block">es obligatorio</span>')

  $(document).on 'click', '.download-assets', (e) ->
    e.preventDefault()
    window.location = $(@).data('url')

  #USER AUTOCOMPLETE
  $("#admin-new-user .typeahead").keyup (e) ->
    unless e.which == 13
      $form = $('#admin-new-user')
      if $form.find('input:hidden[value="patch"]').length > 0
        $form.find('input:hidden:first').next().remove()
        $form.attr('action', $form.data('url-users'))
        $form.find('#user_username').val('')
        $form.find('#user_role').val('super_admin')

  bestPictures = new Bloodhound(
    datumTokenizer: Bloodhound.tokenizers.obj.whitespace("name")
    queryTokenizer: Bloodhound.tokenizers.whitespace
    limit: 100
    remote: decodeURIComponent($("#admin-new-user .typeahead").data('url'))
  )
  bestPictures.initialize()
  $("#admin-new-user input.typeahead").typeahead null,
    displayKey: "name"
    source: bestPictures.ttAdapter()
  .on 'typeahead:selected', (evt, data) ->
    $form = $('#admin-new-user')
    url = decodeURIComponent($form.data('url-user'))
    if $form.find('input:hidden[value="patch"]').length == 0
      $('<input type="hidden" value="patch" name="_method" autocomplete="off">').insertAfter( $form.find('input:hidden:first') )
      $form.attr('action', url.replace(/{id}/, data.id))
      $form.find('#user_username').val(data.username)
      $form.find('#user_role').val(data.role)

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
  $("<div class='input-group'></div>").insertBefore("input#entry_subarticle_date")
  $("input#entry_subarticle_date").appendTo(".input-group")
  $("<span class='input-group-addon glyphicon glyphicon-calendar'></span>").insertAfter("input#entry_subarticle_date")

  $(".date").datepicker
    format: "dd/mm/yyyy"
    language: "es"

  $("input#entry_subarticle_amount").keyup ->
    total_cost()

  $("input#entry_subarticle_unit_cost").keyup ->
    total_cost()
