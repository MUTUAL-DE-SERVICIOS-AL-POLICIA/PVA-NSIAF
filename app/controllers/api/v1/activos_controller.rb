module Api
  module V1
    class ActivosController < ApplicationController

      respond_to :json

      def index
        activos =
          if params[:barcode].present?
            Asset.buscar_por_barcode(params[:barcode])
          else
            Asset.all
          end
        sumatoria = 0
        activos.map{ |a| sumatoria += a.precio }
        render json: { activos: activos, sumatoria: sumatoria }
      end
    end
  end
end
