module Api
  module V1
    class ActivosController < ApplicationController

      respond_to :json

      def index
        if params[:barcode].present?
          barcode = params[:barcode]
          activos = Asset.buscar_por_barcode(barcode)
          render json: activos, root: false
        else
          render json: Asset.all, root:false
        end
      end
    end
  end
end
