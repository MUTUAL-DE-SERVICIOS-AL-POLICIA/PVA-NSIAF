jQuery ->
  $(".datatable").dataTable
    sPaginationType: "bootstrap"
    bProcessing: false
    bServerSide: true
    bLengthChange: false
    iDisplayLength: 15
    aoColumnDefs: [
      { bSortable: false, aTargets: [ -1 ] }
    ]
    oLanguage:
      sUrl: '/locales/dataTables.spanish.txt'
    sDom: 'T<"clear">lfrtip',
    oTableTools:
      sSwfPath: "/swf/copy_csv_xls_pdf.swf"
      aButtons: [
        { sExtends: 'copy', sButtonText: 'Copiar' },
        { sExtends: 'csv', sButtonText: 'CSV' },
        { sExtends: 'pdf', sButtonText: 'PDF' },
        { sExtends: 'print', sButtonText: 'Imprimir' }
      ]
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

  # Change button status
  $(document).on 'click', '.datatable .btn-warning', (evt) ->
    tpl = $('#destroy-modal').html()
    data = $(@).data()
    html = Hogan.compile(tpl).render(data)
    $('#confirm-modal').html(html)
    $("#modal-#{ $(@).data('dom-id') }").modal('toggle')
    evt.preventDefault()

  $(document).on 'click', '.modal .btn-primary', ->
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
