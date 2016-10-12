module Api
  module V1
    class ReportesController < ApplicationController
      def activos
        #desde, hasta = get_fechas(params, false)
        desde, hasta = nil, nil
        q = params[:q]
        cuentas = params[:cuentas]
        col = params[:col]
        @activos = Asset.buscar(col, q, cuentas, desde, hasta).order(:code)
        @total = @activos.inject(0.0) { |total, activo| total + activo.precio }
        respond_to do |format|
          format.json {
            if @activos.present?
              render json: @activos, each_serializer: ActivoSerializer, root: false,
                     status: 200
            else
              render json: { mensaje: 'No tiene activos asignados.' },
                     status: 404
            end
          }
        end
      end
    end
  end
end
