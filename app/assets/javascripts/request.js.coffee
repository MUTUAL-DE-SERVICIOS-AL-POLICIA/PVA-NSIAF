jQuery ->
  app = new Request()

class Request extends AssetEvents
  cacheElements: ->
    @$request = $('#request')
    @$barcode = $('#barcode')
    @$table_request = $('#table_request')
    @$alert_modal = $("#alert_modal")
    @$content_modal = $('#content_modal')

    @$idRequest = $('#request_id').text()

    @$btnEditRequest = $('#btn_edit_request')
    @$btnShowRequest = $('#btn-show-request')
    @$btnSaveRequest = $('#btn_save_request')
    @$btnCancelRequest = $('#btn_cancel_request')
    @$btnDeliverRequest = $('#btn_deliver_request')
    @$btnSendRequest = $('#btn_send_request')

    @$templateRequestButtons = Hogan.compile $('#request_buttons').html() || ''
    @$templateRequestAccept = Hogan.compile $('#request_accept').html() || ''
    @$templateRequestInput = Hogan.compile $('#request_input').html() || ''
    @$templateRequestBarcode = Hogan.compile $('#request_barcode').html() || ''

    @request_save_url = '/requests/'

  bindEvents: ->
    $(document).on 'click', @$btnShowRequest.selector, => @show_request()
    $(document).on 'click', @$btnEditRequest.selector, => @edit_request()
    $(document).on 'click', @$btnSaveRequest.selector, => @save_request()
    $(document).on 'click', @$btnCancelRequest.selector, => @cancel_request()
    $(document).on 'click', @$btnDeliverRequest.selector, => @deliver_request()
    $(document).on 'click', @$btnSendRequest.selector, => @send_request()

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

  save_request: ->
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
    @$content_modal.html(content)
    @$alert_modal.modal('toggle')
