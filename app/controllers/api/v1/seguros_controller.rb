module Api
  module V1
    class SegurosController < ApplicationController
      before_action :set_usuario, only: [:create]
      before_action :set_seguro, only: [:update]

      respond_to :json

      def create
        @seguro = Seguro.new(seguro_params)
        @seguro.user = @usuario
        respond_to do |format|
          if @seguro.save
            format.json { render json: @seguro, root: false, status: :created }
          else
            format.json { render json: @seguro.errors, status: :unprocessable_entity }
          end
        end
      end

      def update
        respond_to do |format|
          if @seguro.update(seguro_params)
            format.html { redirect_to @seguro, notice: 'Seguro creado exitosamente.' }
            format.json { render json: @seguro,  root: false, status: :created }
          else
            format.html { render action: 'new' }
            format.json { render json: @seguro.errors, status: :unprocessable_entity }
          end
        end
      end

      private

      def set_seguro
        @seguro = Seguro.find(params[:id])
      end

      def set_usuario
        @usuario = current_user
      end

      def seguro_params
        params.require(:seguro).permit(:supplier_id, :user_id, :numero_contrato, :factura_numero, :factura_autorizacion, :factura_fecha, :fecha_inicio_vigencia, :fecha_fin_vigencia, :baja_logica, asset_ids: [])
      end
    end
  end
end
