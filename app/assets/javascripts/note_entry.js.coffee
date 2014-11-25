$ -> new NoteEntry() if $('[data-action=note_entry]').length > 0

class NoteEntry extends BarcodeReader
  cacheElements: ->
    @$note_entry_urls = $('#note_entry-urls')

    @$inputSupplier = $('input#supplier')
    @$inputNoteEntrySupplier = $('input#note_entry_supplier_id')
    @formNoteEntry = $('#new_note_entry')
    @btnSaveNoteEntry = $('#save_note_entry .btn-primary')
    @subarticles = $('#subarticles')

    @alert = new Notices({ele: 'div.main'})

  bindEvents: ->
    if @$inputSupplier?
      @get_suppliers()
    $(document).on 'click', @btnSaveNoteEntry.selector, => @get_note_entry()


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
    .on 'typeahead:selected', (evt, data) => @get_supplier_id(evt, data)

  get_supplier_id: (evt, data) ->
    @$inputNoteEntrySupplier.val(data.id)

  get_note_entry: ->

    if @$inputSupplier.val() == ''
      @$inputSupplier.parents('.form-group').addClass('has-error')
      @$inputSupplier.after('<span class="help-block">no puede estar en blanco</span>') unless $('span.help-block').length
      @valid = false
    else
      @$inputSupplier.parents('.form-group').removeClass('has-error')
      @$inputSupplier.next().remove()
      @valid = true

    if @subarticles.find('tr').length <= 2
      @open_modal 'Debe añadir al menos un material'
      @valid = false
    else
      @subarticles.find('tr.subarticle').each (i) ->
        if $.isNumeric($(this).find('.amount').val()) && $.isNumeric($(this).find('.unit_cost').val())
          $(this).removeClass('danger')
          $(this).find('input').attr('style', '')
          @valid = true
        else
          $(this).addClass('danger')
          $(this).find('input').css('background-color', '#f2dede')
          new Notices({ele: 'div.main'}).danger "Verifique los campos a llenar del material '#{$(this).find('.description').text()}'"
          @valid = false
      @valid = @valid

    if @valid
      $.post @formNoteEntry.attr('action'), @formNoteEntry.serialize(), null, 'script'


  open_modal: (content) ->
    @alert.danger content
