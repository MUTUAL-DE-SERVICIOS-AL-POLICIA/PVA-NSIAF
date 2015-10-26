module Api
  module V1
    class NotaEntradasController < ApplicationController
      respond_to :json

      def index
        render json: NoteEntry.unscoped.order(:note_entry_date), status: 200, each_serializer: NotaEntradaSerializer
      end
    end
  end
end
