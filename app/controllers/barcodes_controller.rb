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
      format.json { render json: {} }
    end
  end

  def auxiliary
    @auxiliary = true
    respond_to do |format|
      format.html { render :index }
      format.json { render json: {} }
    end
  end
end
