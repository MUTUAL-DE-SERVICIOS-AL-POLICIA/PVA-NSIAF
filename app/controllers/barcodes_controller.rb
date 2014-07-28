class BarcodesController < ApplicationController
  load_and_authorize_resource class: false

  def index
    authorize! :index, :barcode
    respond_to do |format|
      format.html
      format.json { render json: {} }
    end
  end

  def account
    authorize! :account, :barcode
    respond_to do |format|
      format.html
      format.json { render json: {} }
    end
  end

  def asset
    authorize! :asset, :barcode
    @asset = true
    @assets = Asset.array_model('assets.code', 'asc', '', '', params[:sSearch], params[:search_column], 1)
    respond_to do |format|
      format.html { render :index }
      format.js
      format.json do
        assets = Asset.search_by(params[:account], params[:auxiliary])
        render json: view_context.selected_assets_json(assets)
      end
    end
  end

  def auxiliary
    authorize! :auxiliary, :barcode
    @auxiliary = true
    respond_to do |format|
      format.html { render :index }
      format.json { render json: Auxiliary.search_by(params[:account]) }
    end
  end

  def pdf
    authorize! :pdf, :barcode
    @assets = Asset.where(code: params[:asset_codes])
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
                 bottom: 10,
                 left: 10,
                 right: 10
               }
      end
    end
  end
end
