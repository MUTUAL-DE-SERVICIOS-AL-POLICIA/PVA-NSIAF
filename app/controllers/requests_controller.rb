class RequestsController < ApplicationController
  load_and_authorize_resource
  before_action :set_request, only: [:show]

  # GET /requests
  def index
    format_to('requests', RequestsDatatable)
  end

  # GET /requests/1
  def show
    respond_to do |format|
      format.html
      format.json { render json: @request.delivery_verification(params[:barcode]) }
      format.pdf do
        render pdf: "VSIAF-Pedido-Artículo",
               disposition: 'attachment',
               template: 'requests/show.html.haml',
               layout: 'pdf.html',
               page_size: 'Letter',
               margin: { top: 10, bottom: 15, left: 20, right: 15 },
               header: { html: { template: 'shared/header.pdf.haml' } },
               footer: { html: { template: 'shared/footer.pdf.haml' } }
      end
    end
  end

  # GET /requests/new
  def new
  end

  # POST /requests
  def create
    @request = Request.new(request_params)
    @request.user_id = current_user.id
    @request.save
  end

  # PATCH/PUT /requests/1
  def update
    @request.admin_id = current_user.id
    @request.update(request_params)
    render nothing: true
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_request
      @request = Request.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def request_params
      params.require(:request).permit(:user_id, :status, :delivery_date, { subarticle_requests_attributes: [ :id, :subarticle_id, :amount, :amount_delivered ] } )
    end
end
