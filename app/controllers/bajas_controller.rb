class BajasController < ApplicationController
  load_and_authorize_resource
  #before_action :establece_usuario_actual, only: [:create]

  def index
    if params[:barcode].present?
      barcode = params[:barcode]
      activos = Asset.buscar_por_barcode(barcode)
      render json: activos, root: false
    else
      format_to('assets', AssetsDatatable)
    end
  end

  def new
    @baja = Baja.new(fecha:  Date.today)
  end

  def create
  end

  private

  def baja_params
    params.require(:baja).permit(:documento, :fecha, :observacion)
  end

  #def establece_usuario_actual
  #end
end
