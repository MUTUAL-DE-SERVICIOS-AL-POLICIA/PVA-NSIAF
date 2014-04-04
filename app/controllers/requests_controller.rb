class RequestsController < ApplicationController
  load_and_authorize_resource
  before_action :set_request, only: [:show, :edit, :update, :destroy]

  # GET /requests
  def index
    format_to('requests', RequestsDatatable)
  end

  # GET /requests/1
  def show
  end

  # GET /requests/new
  def new
    @request = Request.new
  end

  # GET /requests/1/edit
  def edit
  end

  # POST /requests
  def create
    @request = Request.new(request_params)

    if @request.save
      redirect_to @request, notice: 'Request was successfully created.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /requests/1
  def update
    if @request.update(request_params)
      redirect_to @request, notice: 'Request was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /requests/1
  def destroy
    @request.destroy
    redirect_to requests_url, notice: 'Request was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_request
      @request = Request.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def request_params
      params.require(:request).permit(:admin_id, :user_id, :material_id, :amount)
    end
end
