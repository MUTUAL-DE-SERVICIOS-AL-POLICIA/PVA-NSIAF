class BarcodesController < ApplicationController
  def index
    respond_to do |format|
      format.html
      format.json { render json: {} }
    end
  end

  def asset
    @asset = true
    respond_to do |format|
      format.html { render :index }
      format.json do
        assets = Asset.search_by(params[:account], params[:auxiliary])
        render json: view_context.selected_assets_json(assets)
      end
    end
  end

  def auxiliary
    @auxiliary = true
    respond_to do |format|
      format.html { render :index }
      format.json { render json: Auxiliary.search_by(params[:account]) }
    end
  end
end
