class IngresosController < ApplicationController
  load_and_authorize_resource
  before_action :set_ingreso, only: [:show, :edit, :update, :destroy]

  # GET /ingresos
  def index
    # format_to('ingresos', IngresosDatatable)
  end

  # GET /ingresos/1
  def show
    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "VSIAF-Nota de Ingreso #{@note_entry.note_entry_date}".parameterize,
               disposition: 'attachment',
               template: 'ingresos/show.html.haml',
               layout: 'pdf.html',
               page_size: 'Letter',
               margin: view_context.margin_pdf,
               header: { html: { template: 'shared/header.pdf.haml' } },
               footer: { html: { template: 'shared/footer.pdf.haml' } }
      end
    end
  end

  # GET /ingresos/new
  def new
    @note_entry = NoteEntry.new
  end

  # GET /ingresos/1/edit
  def edit
    render 'new'
  end

  # POST /ingresos
  def create
    @note_entry = NoteEntry.new(note_entry_params)
    @note_entry.supplier_id = Supplier.get_id(params[:note_entry][:supplier_id])
    @note_entry.user_id = current_user.id
    @note_entry.save
  end

  # PATCH/PUT /ingresos/1
  def update
    respond_to do |format|
      if @note_entry.update(note_entry_params)
        @note_entry.change_date_entries
        @note_entry.change_kardexes
        format.html { redirect_to @note_entry, notice: t('general.updated', model: NoteEntry.model_name.human) }
        format.js
      else
        format.html { render action: 'new' }
      end
    end
  end

  def get_suppliers
    render json: Supplier.search_supplier(params[:q]), root: false
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_note_entry
      @note_entry = NoteEntry.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def note_entry_params
      params.require(:note_entry).permit(:delivery_note_number, :nro_nota_ingreso, :delivery_note_date, :invoice_number, :invoice_autorizacion, :c31, :invoice_date, :supplier_id, :subtotal, :total, :descuento, {entry_subarticles_attributes: [ :id, :subarticle_id, :amount, :unit_cost, :total_cost]})
    end
end
