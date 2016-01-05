class AssetsController < ApplicationController
  load_and_authorize_resource
  before_action :set_asset, only: [:show, :edit, :update, :change_status, :historical]

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
    url = @asset.status == '0' ? derecognised_index_path : assets_url
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
    @asset.derecognised = Time.now
    @asset.decline_user_id = current_user.id
    @asset.update(asset_params)
    @asset.change_status
    render nothing: true
  end

  def users
    department = params[:department].present? ? params[:department] : (params[:q].present? ? params[:q][:request_user_department_id_eq] : '')
    respond_to do |format|
      format.json { render json: User.actives.search_by(department), root: false }
    end
  end

  def departments
    building = params[:building].present? ? params[:building] : params[:q][:request_user_department_building_id_eq]
    respond_to do |format|
      format.json { render json: Department.actives.search_by(building), root: false }
    end
  end

  def search
    asset = Asset.assigned.find_by_barcode params[:code]
    respond_to do |format|
      format.json { render json: asset,
                           include: {user: {only: [:id, :name, :title]}},
                           only: [:id, :description, :code] }
    end
  end

  def admin_assets
    asset = current_user.not_assigned_assets.find_by_barcode params[:code]
    assign = 1
    if asset.blank?
      asset = Asset.find_by_barcode params[:code]
      assign = asset.present? ? 2 : 0
    end
    respond_to do |format|
      format.json { render json: [asset, assign], only: [:id, :description, :code], include: {user: {only: [:name]}}, root: false }
    end
  end

  def historical
    proceedings = Proceeding.includes(:user).joins(:asset_proceedings).where(asset_proceedings: {asset_id: @asset.id}).order(created_at: :desc)
    respond_to do |format|
      format.json { render json: view_context.proceedings_json(proceedings) }
    end
  end

  def recode
  end

  # search by code and description
  def autocomplete
    assets = view_context.search_asset_subarticle(Asset, params[:q])
    respond_to do |format|
      format.json { render json: view_context.assets_json(assets) }
    end
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
        params.require(:asset).permit(:code, :description, :precio, :proceso, :observaciones, :auxiliary_id, :user_id, :barcode, :state)
      else
        params.require(:asset).permit(:code, :description, :precio, :proceso, :observaciones, :barcode, :state, :derecognised, :description_decline, :reason_decline, :decline_user_id)
      end
    end
end
