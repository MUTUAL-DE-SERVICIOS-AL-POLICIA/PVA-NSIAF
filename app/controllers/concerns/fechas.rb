module Fechas
  extend ActiveSupport::Concern

  # Permite convertir un rango de fechas de String a Date
  def get_fechas(params, sw = true)
    formato = '%d-%m-%Y'
    if sw == true
      params[:desde] = params[:desde].present? ? params[:desde] : Date.today.beginning_of_year.strftime(formato)
      params[:hasta] = params[:hasta].present? ? params[:hasta] : Date.today.strftime(formato)
    end
    desde = Date.strptime(params[:desde], formato) if params[:desde].present?
    hasta = Date.strptime(params[:hasta], formato) if params[:hasta].present?
    [desde, hasta]
  end

  def generar_reporte(transacciones)
    transacciones
  end

  def cantidad_entrada(cantidad)
    cantidad >= 0 ? cantidad : 0
  end

  def cantidad_salida(cantidad)
    cantidad < 0 ? -1 * cantidad : 0
  end
end
