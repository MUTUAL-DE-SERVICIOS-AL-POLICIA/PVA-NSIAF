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
      iframe.src = oConfig.sUrl + "?" + $.param(oParams) + "&search_column=#{ $('#select_column').val() }"
      document.body.appendChild iframe
    fnSelect: null
    fnComplete: null
    fnInit: null

  $(".datatable").dataTable
    sPaginationType: "bootstrap"
    bProcessing: false
    bServerSide: true
    bLengthChange: false
    iDisplayLength: 15
    aoColumnDefs: [
      { sClass: 'nowrap', bSortable: false, aTargets: [ -1 ] },
      { sClass: 'nowrap', aTargets: [ 0 ] }
    ]
    oLanguage:
      sUrl: '/locales/dataTables.spanish.txt'
    sDom: 'T<"clear">lfrtip',
    fnServerParams: (aoData) ->
      aoData.push
        name: "search_column"
        value: $('#select_column').val()
    fnInitComplete: ->
      $('.dataTables_filter input').attr('placeholder', 'Buscar...')
      $('.dataTables_filter input').addClass('form-control')
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
    $user = $(this).closest('#confirm-modal').prev().find("[data-dom-id=#{id}]")
    if $user.text() == 'Activar'
      img = 'remove'
      text = 'Desactivar'
      status_td = 'ACTIVO'
    else
      img = 'ok'
      text = 'Activar'
      status_td = 'INACTIVO'
    message = $user.data('confirm-message').replace($user.text(), text)
    $user.data('confirm-message', message)
    $user.parent().prev().text(status_td)
    $user.empty().append("<span class='glyphicon glyphicon-#{img}'></span>#{text}")

  # Ajax loading
  $(document).on 'ajaxStart', (e, xhr, settings, exception) ->
    NProgress.start()
  $(document).on 'ajaxComplete', (e, xhr, settings, exception) ->
    NProgress.done()

  $('#announcements').bind 'close.bs.alert', ->
    $.ajax
      url: '/dashboard/announcements/hide'
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
      alert('Llenar los campos')

  $(document).on 'click', '.download-assets', (e) ->
    e.preventDefault()
    window.location = $(@).data('url')

  #USER AUTOCOMPLETE
  $(".typeahead").keyup (e) ->
    unless e.which == 13
      $form = $('#new_user')
      if $form.find('input:hidden[value="patch"]').length > 0
        $form.find('input:hidden:first').next().remove()
        $form.attr('action', "/users")
        $form.find('#user_username').val('')
        $form.find('#user_role').val('super_admin')

  bestPictures = new Bloodhound(
    datumTokenizer: Bloodhound.tokenizers.obj.whitespace("name")
    queryTokenizer: Bloodhound.tokenizers.whitespace
    limit: 100
    remote: "/users/autocomplete.json?q=%QUERY"
  )
  bestPictures.initialize()
  $("input.typeahead").typeahead null,
    displayKey: "name"
    source: bestPictures.ttAdapter()
  .on 'typeahead:selected', (evt, data) ->
    $form = $('#new_user')
    if $form.find('input:hidden[value="patch"]').length == 0
      $('<input type="hidden" value="patch" name="_method" autocomplete="off">').insertAfter( $form.find('input:hidden:first') )
      $form.attr('action', "/users/#{data.id}")
      $form.find('#user_username').val(data.username)
      $form.find('#user_role').val(data.role)
