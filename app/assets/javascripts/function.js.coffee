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
