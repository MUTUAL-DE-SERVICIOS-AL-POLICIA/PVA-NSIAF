jQuery ->
  $(".datatable").dataTable
    sPaginationType: "bootstrap"
    bJQueryUI: true
    bProcessing: true
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

  # Change button status
  $(document).on 'click', '.datatable .btn-warning', ->
    if $(this).text() == 'Activar'
      img = 'remove'
      text = 'Desactivar'
      status_td = 'ACTIVO'
    else
      img = 'ok'
      text = 'Activar'
      status_td = 'INACTIVO'
    $(this).parent().prev().text(status_td)
    $(this).empty().append("<span class='glyphicon glyphicon-#{img}'></span>#{text}")

  # Ajax loading
  $(document).on 'ajaxStart', (e, xhr, settings, exception) ->
    NProgress.start()
  $(document).on 'ajaxComplete', (e, xhr, settings, exception) ->
    NProgress.done()

