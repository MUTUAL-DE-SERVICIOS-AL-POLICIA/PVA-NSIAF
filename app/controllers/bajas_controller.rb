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

  def obt_cod_ingreso
    resultado = Hash.new
    if params[:d].present?
      fecha = params[:d].to_date
      if params[:n].present?
        nota_ingreso = Baja.find(params[:n])
        unless nota_ingreso.numero.present?
          resultado = Baja.obtiene_siguiente_numero_ingreso(fecha)
        end
      else
        resultado = Baja.obtiene_siguiente_numero_ingreso(fecha)
      end
      if resultado[:tipo_respuesta] == 'confirmacion'
        resultado[:titulo] = "Confirmación de Ingreso"
      elsif resultado[:tipo_respuesta] == 'alerta'
        resultado[:titulo] = "Alerta de Ingreso"
      end
    end
    render json: resultado, root: false
  end

  private

  def baja_params
    params.require(:baja).permit(:documento, :fecha, :observacion, asset_ids: [])
  end

  def obtener_admin_activos
    @admin_ids = User.where(role: 'admin').map &:id
  end
end
