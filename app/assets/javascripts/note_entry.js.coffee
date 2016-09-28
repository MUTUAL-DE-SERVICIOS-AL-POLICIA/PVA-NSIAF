$ -> new NoteEntry() if $('[data-action=note_entry]').length > 0

class NoteEntry extends BarcodeReader
  cacheElements: ->
    @$note_entry_urls = $('#note_entry-urls')

    @$inputSupplier = $('input#note_entry_supplier_id')
    @formNoteEntry = $('#new_note_entry')
    @btnSaveNoteEntry = $('#save_note_entry .btn-primary')
    @$subarticles = $('#subarticles')
    @$subtotalSuma = @$subarticles.find('.subtotal-suma')
    @$descuento = @$subarticles.find('.descuento')
    @$totalSuma = @$subarticles.find('.total-suma')
    @$inputTotal = $('#note_entry_total')
    @$inputSubtotal = $('#note_entry_subtotal')

    @alert = new Notices({ele: 'div.main'})
    # Contenedores
    @$confirmModal = $('#confirm-modal')
    @$confirmarNotaIngresoModal = $('#modal-confirmar-nota-ingreso')

    # Plantillas
    @$ConfirmarNotaIngresoTpl = Hogan.compile $('#confirmar-nota-ingreso-tpl').html() || ''

  bindEvents: ->
    if @$inputSupplier?
      @get_suppliers()
    $(document).on 'click', @btnSaveNoteEntry.selector, (e) => @get_note_entry(e)
    $(document).on 'keyup', '.amount, .unit_cost, .descuento', (e) => @actualizarTotales(e)
    $(document).on 'click', @$confirmarNotaIngresoModal.find('button[type=submit]').selector, (e) => @aceptarNotaIngreso(e)

  confirmarNotaIngreso: (e) ->
    e.preventDefault()
    @$confirmModal.html @$ConfirmarNotaIngresoTpl.render()
    modal = @$confirmModal.find(@$confirmarNotaIngresoModal.selector)
    modal.modal('show')

  aceptarNotaIngreso: (e) ->
    e.preventDefault()
    @$confirmModal.find(@$confirmarNotaIngresoModal.selector).modal('hide')
    $form = $(e.target).closest('form')
    $.post @formNoteEntry.attr('action'), @formNoteEntry.serialize(), null, 'script'

  actualizarTotales: (e) ->
    @mostrarTotalParcial($(e.target))
    @mostrarSubtotal()
    @mostrarTotal()

  get_suppliers: ->
    bestPictures = new Bloodhound(
      datumTokenizer: Bloodhound.tokenizers.obj.whitespace("description")
      queryTokenizer: Bloodhound.tokenizers.whitespace
      limit: 100
      remote: decodeURIComponent @$note_entry_urls.data('get-suppliers')
    )
    bestPictures.initialize()
    @$inputSupplier.typeahead null,
      displayKey: "name"
      source: bestPictures.ttAdapter()

  get_note_entry: (e)->
    if @$inputSupplier.val()
      @$inputSupplier.parents('.form-group').removeClass('has-error')
      @$inputSupplier.next().remove()
      @valid = true
    else
      @$inputSupplier.parents('.form-group').addClass('has-error')
      @$inputSupplier.after('<span class="help-block">no puede estar en blanco</span>') unless $('span.help-block').length
      @valid = false

    if @$subarticles.find('tr.subarticle').length
      @$subarticles.find('tr.subarticle').each (i) ->
        if $.isNumeric($(this).find('.amount').val()) && $.isNumeric($(this).find('.unit_cost').val())
          $(this).removeClass('danger')
          $(this).find('input').attr('style', '')
          @valid = true
        else
          $(this).addClass('danger')
          $(this).find('input').css('background-color', '#f2dede')
          new Notices({ele: 'div.main'}).danger "Verifique los campos a llenar del material '#{$(this).find('.description').text()}'"
          @valid = false
      @valid
    else
      @open_modal 'Debe añadir al menos un material'
      @valid = false

    if @valid
      @confirmarNotaIngreso(e)

  open_modal: (content) ->
    @alert.danger content

  mostrarSubtotal: ->
    sumaSubtotal = @sumarSubtotal()
    @$subtotalSuma.text sumaSubtotal.formatNumber(2, '.', ',')
    @$inputSubtotal.val(sumaSubtotal)

  mostrarTotal: ->
    sumaTotal = @sumarTotal()
    @$totalSuma.text sumaTotal.formatNumber(2, '.', ',')
    @$inputTotal.val(sumaTotal) # establecer el total

  mostrarTotalParcial: ($elem) ->
    $fila = $elem.closest('tr')
    totalParcial = @totalParcial($fila)
    $fila.find('.total-parcial').text totalParcial.formatNumber(2, '.', ',')
    $fila.find('input.total-cost').val totalParcial # establecer total parcial

  descuento: ->
    if $.isNumeric(@$descuento.val())
      parseFloat @$descuento.val()
    else
      0

  sumarSubtotal: ->
    @$subarticles.find('tr.subarticle').toArray().reduce (suma, fila) =>
      suma + @totalParcial($(fila))
    , 0

  sumarTotal: ->
    @sumarSubtotal() - @descuento()

  totalParcial: ($fila) ->
    amount = parseFloat($fila.find('input.amount').val()) || 0
    unit_cost = parseFloat($fila.find('input.unit_cost').val()) || 0
    amount * unit_cost
