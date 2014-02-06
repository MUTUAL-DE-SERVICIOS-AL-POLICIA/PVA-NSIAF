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
      sInfo: "Mostrando _START_ al _END_ de _TOTAL_ registros"
      oPaginate:
        sPrevious: "Anterior"
        sNext: "Siguiente"

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
