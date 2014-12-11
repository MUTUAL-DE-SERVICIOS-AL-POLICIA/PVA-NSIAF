$ -> new NoteEntry() if $('[data-action=note_entry]').length > 0

class NoteEntry extends BarcodeReader
  cacheElements: ->
    @$note_entry_urls = $('#note_entry-urls')

    @$inputSupplier = $('input#note_entry_supplier_id')
    @formNoteEntry = $('#new_note_entry')
    @btnSaveNoteEntry = $('#save_note_entry .btn-primary')
    @subarticles = $('#subarticles')
    @btnNewEntry = $('#new_entry')

    @alert = new Notices({ele: 'div.main'})

  bindEvents: ->
    if @$inputSupplier?
      @get_suppliers()
    $(document).on 'click', @btnSaveNoteEntry.selector, => @get_note_entry()
    $(document).on 'click', @btnNewEntry.selector, => @new_entry()


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
    if @$inputSupplier.val() == ''
      @$inputSupplier.parents('.form-group').addClass('has-error')
      @$inputSupplier.after('<span class="help-block">no puede estar en blanco</span>') unless $('span.help-block').length
      @valid = false
    else
      @$inputSupplier.parents('.form-group').removeClass('has-error')
      @$inputSupplier.next().remove()
      @valid = true

    if @subarticles.find('tr.subarticle').length
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
    else
      @open_modal 'Debe añadir al menos un material'
      @valid = false

    if @valid
      $.post @formNoteEntry.attr('action'), @formNoteEntry.serialize(), null, 'script'


  open_modal: (content) ->
    @alert.danger content

  new_entry: ->
    $new_entry = $('form#new_entry_subarticle')
    $amount = $new_entry.find('.amount')
    $unit_cost = $new_entry.find('.unit_cost')
    $date = $new_entry.find('.date')
    @valid_entry($.isNumeric($unit_cost.val()), $unit_cost)
    @valid_entry($date.val()!='', $date, true)
    if @valid_entry($.isNumeric($amount.val()), $amount) && @valid_entry($.isNumeric($unit_cost.val()), $unit_cost) && @valid_entry($date.val()!='', $date, true)
      $.post($new_entry.attr('action'), $new_entry.serialize()).done (params) ->
        id = $new_entry.find('input#entry_subarticle_subarticle_id').val()
        $("a.btn-success[data-id='#{id}']").remove()
        $new_entry.parents('.modal').modal('hide')

  valid_entry: (condition, $input, date = false) ->
    input = if date then $input.parent() else $input
    if condition
      input.parent().parent().removeClass('has-error')
      input.next().remove()
      true
    else
      input.parent().parent().addClass('has-error')
      input.after('<span class="help-block">valor erróneo</span>') unless input.next().length
      false
