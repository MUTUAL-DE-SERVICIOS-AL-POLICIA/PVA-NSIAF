class KardexesController < ApplicationController
  before_action :set_kardex, only: [:show, :edit, :update, :destroy]

  include Fechas

  # GET /kardexes
  def index
    if params[:subarticle_id].present?
      @subarticle = Subarticle.find(params[:subarticle_id])

      desde, hasta = get_fechas(params)
      @transacciones = @subarticle.kardexs(desde, hasta)
      @year = desde.year
    else
      @kardexes = Kardex.all
    end
    respond_to do |format|
      format.html
      format.pdf do
        filename = @subarticle.description.parameterize || 'subarticulo'
        render pdf: filename,
               disposition: 'attachment',
               layout: 'pdf.html',
               # show_as_html: params.key?('debug'),
               template: 'kardexes/index.html.haml',
               orientation: 'Landscape',
               page_size: 'Letter',
               margin: view_context.margin_pdf,
               header: { html: { template: 'shared/header.pdf.haml' } },
               footer: { html: { template: 'shared/footer.pdf.haml' } }
      end
    end
  end

  # GET /kardexes/1
  def show
  end

  # GET /kardexes/new
  def new
    @kardex = Kardex.new
  end

  # GET /kardexes/1/edit
  def edit
  end

  # POST /kardexes
  def create
    @kardex = Kardex.new(kardex_params)

    if @kardex.save
      redirect_to :back, notice: t('general.created', model: Kardex.model_name.human)
    else
      render :new
    end
  end

  # PATCH/PUT /kardexes/1
  def update
    if @kardex.update(kardex_params)
      redirect_to @kardex, notice: 'Kardex was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /kardexes/1
  def destroy
    @kardex.destroy
    redirect_to kardexes_url, notice: 'Kardex was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_kardex
      @kardex = Kardex.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def kardex_params
      params.require(:kardex).permit(:kardex_date, :invoice_number, :order_number, :detail, :subarticle_id, kardex_prices_attributes: [:id, :input_quantities, :output_quantities, :balance_quantities, :unit_cost, :input_amount, :output_amount, :balance_amount])
    end
end
