class IngresosController < ApplicationController
  load_and_authorize_resource
  before_action :set_ingreso, only: [:show, :edit, :update, :destroy]

  # GET /ingresos
  def index
    if params[:barcode].present?
      barcode = params[:barcode]
      activos = Asset.buscar_por_barcode(barcode)
      render json: activos, root: false
    else
      format_to('ingresos', IngresosDatatable)
    end
  end

  # GET /ingresos/1
  def show
    @activos = @ingreso.assets.order(:barcode)
    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "Ingreso #{@ingreso.nota_entrega_fecha}".parameterize,
               disposition: 'attachment',
               template: 'ingresos/show.html.haml',
               layout: 'pdf.html',
               page_size: 'Letter',
               show_as_html: params[:debug].present?,
               margin: view_context.margin_pdf,
               header: { html: { template: 'shared/header.pdf.haml' } },
               footer: { html: { template: 'shared/footer.pdf.haml' } }
      end
    end
  end

  # GET /ingresos/new
  def new
    # @note_entry = NoteEntry.new
  end

  # GET /ingresos/1/edit
  def edit
    # render 'new'
  end

  # POST /ingresos
  def create
    @ingreso = current_user.ingresos.new(ingreso_params)
    respond_to do |format|
      if @ingreso.save
        format.html { redirect_to @ingreso, notice: 'Ingreso creado exitosamente' }
        format.json { render json: @ingreso, status: :created }
      else
        format.html { render :new }
        format.json { render json: @ingreso.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /ingresos/1
  def update
    # respond_to do |format|
    #   if @note_entry.update(note_entry_params)
    #     @note_entry.change_date_entries
    #     @note_entry.change_kardexes
    #     format.html { redirect_to @note_entry, notice: t('general.updated', model: NoteEntry.model_name.human) }
    #     format.js
    #   else
    #     format.html { render action: 'new' }
    #   end
    # end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_ingreso
      @ingreso = Ingreso.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def ingreso_params
      params.require(:ingreso).permit(:supplier_id, :factura_numero, :factura_autorizacion, :factura_fecha, :nota_entrega_numero, :nota_entrega_fecha, :c31_numero, :c31_fecha, :total, asset_ids: [])
    end
end
