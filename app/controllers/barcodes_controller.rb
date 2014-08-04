class BarcodesController < ApplicationController
  load_and_authorize_resource class: false

  def index
    authorize! :index, :barcode
    respond_to do |format|
      format.html
      format.json { render json: {} }
    end
  end

  def load_data
    authorize! :load_data, :barcode
    respond_to do |format|
      format.json { render json: {last_value: get_last_value()} }
    end
  end

  def pdf
    authorize! :pdf, :barcode
    @assets = generate_array_with_codes(params[:quantity].to_i)
    Barcode.register_assets(@assets) if @assets.length > 0
    respond_to do |format|
      format.pdf do
        filename = 'código de barras'
        render pdf: "VSIAF-#{filename}".parameterize,
               disposition: 'attachment',
               template: 'barcodes/show.pdf.haml',
               show_as_html: params[:debug].present?,
               orientation: 'Portrait',
               layout: 'pdf.html',
               page_size: 'Letter',
               margin: {
                 top: 10,
                 bottom: 0,
                 left: 0,
                 right: 0
               }
      end
    end
  end

  private

  def generate_array_with_codes(quantity)
    last_value = get_last_value()
    acronym = last_value.split('-').first
    offset = last_value.split('-').last.to_i
    (1..quantity).to_a.map {|i| {code: "#{acronym}-#{offset + i}"}}
  end

  def get_last_value()
    last_value = Barcode.last
    if last_value.present?
      last_value = last_value.code
    else
      acronym = 'ADSIB'
      entity = Entity.first
      acronym = entity.acronym if entity.present?
      last_value = "#{acronym}-0"
    end
    last_value
  end
end
