jQuery ->
  app = new Request()

class Request extends BarcodeReader
  cacheElements: ->
    @$request = $('#request')
    @$barcode = $('#barcode')
    @$table_request = $('#table_request')
    @$material = $('#material')
    @$article = $('#subarticle_article_id')
    @$inputSubarticle = $('input#subarticle')
    @$subarticles = $('#subarticles')
    @$selectionSubarticles = $('#selection_subarticles')
    @$selected_subarticles = $('#selected_subarticles')

    @$idRequest = $('#request_id').text()

    @$btnEditRequest = $('#btn_edit_request')
    @$btnShowRequest = $('#btn-show-request')
    @$btnSaveRequest = $('#btn_save_request')
    @$btnCancelRequest = $('#btn_cancel_request')
    @$btnDeliverRequest = $('#btn_deliver_request')
    @$btnSendRequest = $('#btn_send_request')
    @btnSubarticleRequestPlus = $('#plus_sr')
    @btnSubarticleRequestMinus = $('#minus_sr')
    @btnSubarticleRequestRemove = $('#remove_sr')
    @btnShowNewRequest = $('#btn-show-new-request')
    @$btnCancelNewRequest = $('#btn_cancel_new_request')
    @$btnSaveNewRequest = $('#btn_save_new_request')

    @$templateRequestButtons = Hogan.compile $('#request_buttons').html() || ''
    @$templateRequestAccept = Hogan.compile $('#request_accept').html() || ''
    @$templateRequestInput = Hogan.compile $('#request_input').html() || ''
    @$templateRequestBarcode = Hogan.compile $('#request_barcode').html() || ''
    @$templateNewRequest = Hogan.compile $('#new_request').html() || ''
    @$templateBtnsNewRequest = Hogan.compile $('#cancel_new_request').html() || ''

    @request_save_url = '/requests/'
    @articles_json_url = '/subarticles/articles.json'
    @subarticles_json_url = '/subarticles/get_subarticles.json?q=%QUERY'

    @alert = new Notices({ele: 'div.main'})

  bindEvents: ->
    $(document).on 'click', @$btnShowRequest.selector, => @show_request()
    $(document).on 'click', @$btnEditRequest.selector, => @edit_request()
    $(document).on 'click', @$btnSaveRequest.selector, => @update_request()
    $(document).on 'click', @$btnCancelRequest.selector, => @cancel_request()
    $(document).on 'click', @$btnDeliverRequest.selector, => @deliver_request()
    $(document).on 'click', @$btnSendRequest.selector, => @send_request()
    $(document).on 'click', @btnSubarticleRequestPlus.selector, (e) => @subarticle_request_plus(e)
    $(document).on 'click', @btnSubarticleRequestMinus.selector, (e) => @subarticle_request_minus(e)
    $(document).on 'click', @btnSubarticleRequestRemove.selector, (e) => @subarticle_request_remove(e)
    $(document).on 'click', @btnShowNewRequest.selector, => @show_new_request()
    $(document).on 'click', @$btnCancelNewRequest.selector, => @cancel_new_request()
    $(document).on 'click', @$btnSaveNewRequest.selector, => @save_new_request()
    if @$material?
      @$article.remoteChained(@$material.selector, @articles_json_url)
    if @$inputSubarticle?
      @get_subarticles()

  show_request: ->
    @$table_request.find('.col-md-2 :input').each ->
      val = $(this).val()
      val = if val then val else 0
      $(this).parent().html val
    @$table_request.find('.text-center').hide()
    @$table_request.append @$templateRequestButtons.render()

  edit_request: ->
    @show_buttons()
    @$request.find('table thead tr').append '<th>Cantidad a entregar</th>'
    @$request.find('table tbody tr').append @$templateRequestInput.render()

  update_request: ->
    materials = $.map(@$request.find('tbody tr'), (val, i) ->
      id: val.id
      amount_delivered: $(val).find('td.col-md-2').text()
    )
    data = { status: 'pending', subarticle_requests_attributes: materials }
    $.ajax
      type: "PUT"
      url: @request_save_url + @$idRequest
      data: { request: data }
      complete: (data, xhr) ->
        window.location = window.location

  cancel_request: ->
    @$table_request.find('.text-center').show()
    @$table_request.find('.text-center').next().remove()
    @input_to_text()

  deliver_request: ->
    @show_buttons()
    $('#btn-show-request').remove()
    @$barcode.html @$templateRequestBarcode.render()

  send_request: ->
    @$code = $('#code')
    if @$code.val()
      @changeToHyphens()
      $.getJSON "/requests/#{@$idRequest}", { barcode: @$code.val().trim(), user_id: @$functionary }, (data) => @request_delivered(data)
    else
      @open_modal('Debe ingresar un código de barra')

  show_buttons: ->
    @$request.prev().find(".buttonRequest").remove()
    @$table_request.find('.text-center').html @$templateRequestAccept.render()

  request_delivered: (data) ->
    if data
      if data.amount
        if @$table_request.find("tr##{data.id} td.delivered span.glyphicon-ok").length
          @open_modal("#{data.amount_delivered} es límite de entrega del Sub Artículo con código de barra '#{@$code.val()}'")
        else
          @$table_request.find("tr##{data.id} td.amount_delivered").html data.total_delivered
          if data.total_delivered == data.amount_delivered
            @$table_request.find("tr##{data.id} td.delivered span").addClass 'glyphicon-ok'
            window.location = window.location unless @$table_request.find('.delivered span:hidden').length
      else
        @open_modal("El inventario del Sub Artículo con código de barra '#{@$code.val()}' es 0")
    else
      @open_modal('No se encuentra el Sub Artículo en la lista')

  input_to_text: ->
    @$table_request.find('td.col-md-2').each ->
      $(this).html "<input class='form-control input-sm' type='text' value=#{$(this).text()}>" if $(this).next().text() < $(this).text()

  open_modal: (content) ->
    @alert.danger content

  get_subarticles: ->
    bestPictures = new Bloodhound(
      datumTokenizer: Bloodhound.tokenizers.obj.whitespace("description")
      queryTokenizer: Bloodhound.tokenizers.whitespace
      limit: 100
      remote: @subarticles_json_url
    )
    bestPictures.initialize()
    @$inputSubarticle.typeahead null,
      displayKey: "description"
      source: bestPictures.ttAdapter()
    .on 'typeahead:selected', (evt, data) => @add_subarticle(evt, data)

  add_subarticle: (evt, data) ->
    if @$subarticles.find("tr##{data.id}").length
      @open_modal("El Sub Artículo '#{data.description}' ya se encuentra en lista")
    else
      @$subarticles.append @$templateNewRequest.render(data)

  subarticle_request_plus: ($this) ->
    amount = @get_amount($this)
    $.getJSON "/subarticles/#{ amount.parent().attr('id') }/verify_amount", { amount: parseInt(amount.text()) + 1 }, (data) => @verify_amount(data)

  verify_amount: (data, amount) ->
    if data.there_amount
      amount = @$subarticles.find("tr##{data.id} .amount")
      amount.text(parseInt(amount.text()) + 1)
    else
      @open_modal("Ya no se encuentra la cantidad requerida en el inventario del Sub Artículo '#{data.description}'")

  subarticle_request_minus: ($this) ->
    amount = @get_amount($this)
    amount.text(parseInt(amount.text()) - 1) unless amount.text() is '1'

  subarticle_request_remove: ($this) ->
    @get_amount($this).parent().remove()

  get_amount: ($this) ->
    $($this.currentTarget).parent().prev()

  show_new_request: ->
    if @$subarticles.find('tr').length
      @btnShowNewRequest.hide()
      @$selectionSubarticles.hide()
      table = @$subarticles.parent().clone()
      table.find('.actions-request').remove()
      table.find('thead tr').prepend '<th>#</th>'
      table.find('#subarticles tr').each (i) ->
        $(this).prepend "<td>#{ i+1 }</td>"
      @$selected_subarticles.html table
      @$selected_subarticles.append @$templateBtnsNewRequest.render()
    else
      @open_modal("Debe seleccionar al menos un Sub Artículo")

  cancel_new_request: ->
    @btnShowNewRequest.show()
    @$selectionSubarticles.show()
    @$selected_subarticles.empty()

  save_new_request: ->
    subarticles = $.map(@$subarticles.find('tr'), (val, i) ->
      subarticle_id: val.id
      amount: $(val).find('td.amount').text()
    )
    json_data = { status: 'initiation', subarticle_requests_attributes: subarticles }
    $.post @request_save_url, { request: json_data }, null, 'script'
