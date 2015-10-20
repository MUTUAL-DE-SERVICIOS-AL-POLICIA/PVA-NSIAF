module Api
  module V1
    class DocumentosController < ApplicationController
      before_action :set_documento, only: [:show]

      respond_to :json

      def show
        respond_with(@documento)
      end

      def create
        @documento = Documento.new(documento_params)
        @documento.save
        respond_with(@documento, location: nil)
      end

      private
        def set_documento
          @documento = Documento.find(params[:id])
        end

        def documento_params
          params.require(:documento).permit(:titulo, :contenido, :formato, :etiquetas)
        end
    end
  end
end
