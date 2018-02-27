class BajasController < ApplicationController
  load_and_authorize_resource
  before_action :obtener_admin_activos, only: [:index]

  def index
    if params[:barcode].present?
      barcode = params[:barcode]
      activos = Asset.where('assets.user_id = ?', @admin_ids)
                     .where('baja_id is null')
                     .buscar_por_barcode(barcode)
      render json: activos, root: false
    else
      format_to('assets', AssetsDatatable)
    end
  end

  def new
    @baja = Baja.new(fecha: Date.today)
  end

  def show
    @baja = Baja.find(params[:id])
    @activos = @baja.assets
  end

  def create
    @baja = current_user.bajas.new(baja_params)
    respond_to do |format|
      if @baja.save
        format.html { redirect_to @baja, notice: 'Ingreso creado exitosamente' }
        format.json { render json: @baja, status: :created }
      else
        format.html { render :new }
        format.json { render json: @baja.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def baja_params
    params.require(:baja).permit(:documento, :fecha, :observacion, asset_ids: [])
  end

  def obtener_admin_activos
    @admin_ids = User.where(role: 'admin').map &:id
  end
end
