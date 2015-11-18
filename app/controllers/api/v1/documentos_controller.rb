module Api
  module V1
    class DocumentosController < ApplicationController
      before_action :set_documento, only: [:show]

      def show
        respond_to do |format|
          format.json {
            if @documento.present?

              render json: @documento.as_json(only: [:id, :titulo, :contenido, :formato, :etiquetas], methods: :creado_el),
                     status: 200
            else
              render json: {mensaje: 'El documento solicitado no existe'},
                     status: 404
            end
          }
        end
      end

      def create
        @documento = Documento.new(documento_params)
        respond_to do |format|
          format.json {
            if @documento.save
              render json: {
                id: @documento.id,
                mensaje: 'Se creó el documento correctamente'
              }, status: 201 # Created
            else
              render json: {mensaje: 'Error al guardar el documento'},
                     status: 400
            end
          }
      end

      private
        def set_documento
          begin
            @documento = Documento.find(params[:id])
          rescue ActiveRecord::RecordNotFound => e
            @documento = nil
          end
        end

        def documento_params
          params.require(:documento).permit(:titulo, :contenido, :formato, :etiquetas)
        end
    end
  end
end
