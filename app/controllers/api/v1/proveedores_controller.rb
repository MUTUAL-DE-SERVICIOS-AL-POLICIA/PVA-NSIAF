module Api
  module V1
    class ProveedoresController < ApplicationController
      respond_to :json

      def index
        render json: Supplier.search_supplier(params[:q]), root: false, status: 200
      end
    end
  end
end
