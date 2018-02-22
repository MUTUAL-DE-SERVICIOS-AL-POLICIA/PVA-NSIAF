class BajasController < ApplicationController
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
    @baja = Baja.new
  end
end
