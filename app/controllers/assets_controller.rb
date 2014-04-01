class AssetsController < ApplicationController
  load_and_authorize_resource
  before_action :set_asset, only: [:show, :edit, :update, :change_status]

  # GET /assets
  # GET /assets.json
  def index
    format_to('assets', AssetsDatatable)
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
    url = @asset.status == '0' ? derecognised_assets_path : assets_url
    respond_to do |format|
      if @asset.update(asset_params)
        format.html { redirect_to url, notice: t('general.updated', model: Asset.model_name.human) }
        format.json { head :no_content }
      else
        format.html { render action: 'form' }
        format.json { render json: @asset.errors, status: :unprocessable_entity }
      end
    end
  end

  def change_status
    @asset.change_status
    Decline.deregister(@asset, params[:description], params[:reason], current_user.id)
    render nothing: true
  end

  def users
    respond_to do |format|
      format.html
      format.json { render json: User.search_by(params[:department]) }
    end
  end

  def departments
    respond_to do |format|
      format.html
      format.json { render json: Department.search_by(params[:building]) }
    end
  end

  def assigned
    user = User.includes(:assets).find(params[:user_id])
    assets = user.assets
    render json: view_context.assets_json(assets, user, true)
  end

  def not_assigned
    user = User.find(params[:user_id])
    assets = current_user.not_assigned_assets
    render json: view_context.assets_json(assets, user)
  end

  def assign
    params[:assets] ||= []
    asset_ids = params[:assets].map { |e| e.to_i }
    user = User.find(params[:user_id])
    asset_ids &= current_user.not_assigned_assets.pluck(:id)
    assets = current_user.not_assigned_assets.where(id: asset_ids)
    render json: view_context.assets_json(assets, user)
  end

  def deallocate
    params[:assets] ||= []
    asset_ids = params[:assets].map { |e| e.to_i }
    user = User.find(params[:user_id])
    asset_ids &= user.asset_ids
    assets = user.assets.where(id: asset_ids)
    render json: view_context.assets_json(assets, user, true)
  end

  def derecognised
    format_to('assets', AssetsDatatable)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_asset
      @asset = Asset.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def asset_params
      if action_name == 'create'
        params[:asset][:user_id] = current_user.id
        params.require(:asset).permit(:code, :description, :auxiliary_id, :user_id)
      else
        params.require(:asset).permit(:code, :description)
      end
    end
end
