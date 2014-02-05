jQuery ->
  $(".datatable").dataTable
    sPaginationType: "bootstrap"
    bJQueryUI: true
    bProcessing: true
    bServerSide: true
    sAjaxSource: $('.datatable').data('source')

  $(document).on 'click', '.datatable .btn-warning', ->
    $span = $(this).find('span')
    if $span.text() == 'Activar'
      status_button = 'Desactivar'
      status_td = 'ACTIVO'
    else
      status_button = 'Activar'
      status_td = 'INACTIVO'
    $(this).parent().prev().text(status_td)
    $span.text(status_button)
    $span.toggleClass("glyphicon-remove")
