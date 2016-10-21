module Api
  module V1
    class SegurosController < ApplicationController
      before_action :set_usuario, only: [:create]

      respond_to :json

      def create
        @seguro = Seguro.new(seguro_params)
        @seguro.user = @usuario
        respond_to do |format|
          if @seguro.save
            format.html { redirect_to @seguro, notice: 'Seguro creado exitosamente.' }
            format.json { render json: @seguro,  root: false, status: :created }
          else
            format.html { render action: 'new' }
            format.json { render json: @seguro.errors, status: :unprocessable_entity }
          end
        end
      end

      def update
        debugger
      
        @seguro.user = @usuario
        respond_to do |format|
          if @seguro.save
            format.html { redirect_to @seguro, notice: 'Seguro creado exitosamente.' }
            format.json { render json: @seguro,  root: false, status: :created }
          else
            format.html { render action: 'new' }
            format.json { render json: @seguro.errors, status: :unprocessable_entity }
          end
        end
      end

      private

      def set_usuario
        @usuario = current_user
      end

      def seguro_params
        params.require(:seguro).permit(:supplier_id, :user_id, :numero_contrato, :factura_numero, :factura_autorizacion, :factura_fecha, :fecha_inicio_vigencia, :fecha_fin_vigencia, :baja_logica, asset_ids: [])
      end
    end
  end
end
