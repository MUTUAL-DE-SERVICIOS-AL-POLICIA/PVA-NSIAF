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

  bindEvents: ->
    if @$inputSupplier?
      @get_suppliers()
    $(document).on 'click', @btnSaveNoteEntry.selector, => @get_note_entry()
    $(document).on 'keyup', '.amount, .unit_cost, .descuento', => @actualizarTotales()

  actualizarTotales: ->
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

  get_note_entry: ->
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
      $.post @formNoteEntry.attr('action'), @formNoteEntry.serialize(), null, 'script'

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

  descuento: ->
    if $.isNumeric(@$descuento.val())
      parseFloat @$descuento.val()
    else
      0

  sumarSubtotal: ->
    @$subarticles.find('tr.subarticle').toArray().reduce (suma, fila) ->
      amount = parseInt($(fila).find('input.amount').val()) || 0
      unit_cost = parseFloat($(fila).find('input.unit_cost').val()) || 0
      suma + (amount * unit_cost)
    , 0

  sumarTotal: ->
    @sumarSubtotal() - @descuento()
