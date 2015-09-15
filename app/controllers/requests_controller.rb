class RequestsController < ApplicationController
  load_and_authorize_resource
  before_action :set_request, only: [:show]

  # GET /requests
  def index
    format_to('requests', RequestsDatatable)
  end

  # GET /requests/1
  def show
    @status_pdf = params[:status]
    respond_to do |format|
      format.html
      format.json { render json: @request.delivery_verification(params[:barcode]) }
      format.pdf do
        render pdf: "VSIAF-#{@request.user_name.parameterize || 'materiales'}",
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
    @request.admin_id = current_user.id
    @request.save
    Subarticle.register_log("request")
  end

  # PATCH/PUT /requests/1
  def update
    @request.admin_id = current_user.id
    @request.update(request_params)
    render nothing: true
  end

  def search_subarticles
    if params[:q].present?
      search_date
      date = false
    else
      date = true
    end
    @q = SubarticleRequest.search(params[:q])
    @requests = @q.result.user_requests(date)
    respond_to do |format|
      format.html
      format.js
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_request
      @request = Request.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def request_params
      params.require(:request).permit(:user_id, :status, :delivery_date, :created_at, { subarticle_requests_attributes: [ :id, :subarticle_id, :amount, :amount_delivered ] } )
    end

  def search_date
    case params[:rank]
    when "today"
      params[:q]["request_created_at_gteq"] = Time.now.beginning_of_day
      params[:q]["request_created_at_lteq"] = Time.now.end_of_day
    when "week"
      params[:q]["request_created_at_gteq"] = Time.now.beginning_of_week
      params[:q]["request_created_at_lteq"] = Time.now.end_of_week
    when "month"
      params[:q]["request_created_at_gteq"] = Time.now.beginning_of_month
      params[:q]["request_created_at_lteq"] = Time.now.end_of_month
    when "year"
      params[:q]["request_created_at_gteq"] = Time.now.beginning_of_year
      params[:q]["request_created_at_lteq"] = Time.now.end_of_year
    end
  end
end
