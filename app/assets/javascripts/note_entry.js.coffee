$ -> new NoteEntry() if $('[data-action=note_entry]').length > 0

class NoteEntry extends BarcodeReader
  cacheElements: ->
    @$note_entry_urls = $('#note_entry-urls')

    @$inputSupplier = $('input#supplier')
    @$inputNoteEntrySupplier = $('input#note_entry_supplier_id')

  bindEvents: ->
    if @$inputSupplier?
      @get_suppliers()


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
