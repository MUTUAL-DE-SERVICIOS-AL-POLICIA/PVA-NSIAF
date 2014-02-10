jQuery ->
  $(".datatable").dataTable
    sPaginationType: "bootstrap"
    bJQueryUI: true
    bProcessing: true
    bServerSide: true
    sAjaxSource: $('.datatable').data('source')
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

  # Add username to user
  $('input#user_name').keyup ->
    value = $(this).val()
    initial_name = value[0]
    last_name = value.split(' ')[1]
    if last_name
      user_name = (initial_name + last_name).toLowerCase()
      $('input#user_username').val(user_name)
