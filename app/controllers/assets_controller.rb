class AssetsController < ApplicationController
  before_action :set_asset, only: [:show, :edit, :update, :destroy]

  # GET /assets
  # GET /assets.json
  def index
    respond_to do |format|
      format.html { render '/shared/index' }
      format.json { render json: AssetsDatatable.new(view_context) }
    end
  end

  # GET /assets/1
  # GET /assets/1.json
  def show
  end

  # GET /assets/new
  def new
    @asset = Asset.new
    respond_to do |format|
      format.html { render 'form' }
    end
  end

  # GET /assets/1/edit
  def edit
    respond_to do |format|
      format.html { render 'form' }
    end
  end

  # POST /assets
  # POST /assets.json
  def create
    @asset = Asset.new(asset_params)

    respond_to do |format|
      if @asset.save
        format.html { redirect_to assets_url, notice: t('general.created', model: Asset.model_name.human) }
        format.json { render action: 'show', status: :created, location: @asset }
      else
        format.html { render action: 'form' }
        format.json { render json: @asset.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /assets/1
  # PATCH/PUT /assets/1.json
  def update
    respond_to do |format|
      if @asset.update(asset_params)
        format.html { redirect_to assets_url, notice: t('general.updated', model: Asset.model_name.human) }
        format.json { head :no_content }
      else
        format.html { render action: 'form' }
        format.json { render json: @asset.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /assets/1
  # DELETE /assets/1.json
  def destroy
    @asset.destroy
    respond_to do |format|
      format.html { redirect_to assets_url, notice: t('general.destroy', name: @asset.description) }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_asset
      @asset = Asset.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def asset_params
      params.require(:asset).permit(:code, :description, :auxiliary_id, :user_id)
    end
end
