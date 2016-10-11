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
    params[:desde] = 1 unless params[:desde].present?
    params[:hasta] = 30 unless params[:hasta].present?
    @assets = generate_array_with_codes(params[:desde].to_i, params[:hasta].to_i)
    respond_to do |format|
      format.json { render json: @assets, root: false }
    end
  end

  def pdf
    authorize! :pdf, :barcode
    @assets = generate_array_with_codes(params[:desde].to_i, params[:hasta].to_i)
    # Barcode.register_assets(@assets) if @assets.length > 0
    respond_to do |format|
      format.pdf do
        filename = 'código de barras'
        render pdf: "#{filename}".parameterize,
               disposition: 'attachment',
               template: 'barcodes/show.pdf.haml',
               show_as_html: params[:debug].present?,
               orientation: 'Portrait',
               layout: 'pdf.html',
               page_size: 'Letter',
               margin: {
                 top: 13,
                 bottom: 0,
                 left: 3,
                 right: 3
               }
      end
    end
  end

  private

    def generate_array_with_codes(desde, hasta)
      Asset.where(id: desde..hasta).order(:id)
    end
end
