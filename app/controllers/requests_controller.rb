class RequestsController < ApplicationController
  load_and_authorize_resource
  before_action :set_request, only: [:show]

  # GET /requests
  def index
    format_to('requests', RequestsDatatable)
  end

  # GET /requests/1
  def show
  end

  # GET /requests/new
  def new
    respond_to do |format|
      format.html { render 'assets/users' }
      format.json { render json: view_context.assets_json_request(User.find(params[:user_id])) }
    end
  end

  # POST /requests
  def create
    @request = Request.new(request_params)
    @request.admin_id = current_user.id
    @request.save
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_request
      @request = Request.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def request_params
      params.require(:request).permit(:user_id, { material_requests_attributes: [ :material_id, :amount ] } )
    end
end
