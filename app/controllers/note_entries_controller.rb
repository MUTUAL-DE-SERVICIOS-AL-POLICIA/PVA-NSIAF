class NoteEntriesController < ApplicationController
  load_and_authorize_resource
  before_action :set_note_entry, only: [:show, :edit, :update, :destroy]

  # GET /note_entries
  def index
    format_to('note_entries', NoteEntriesDatatable)
  end

  # GET /note_entries/1
  def show
    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "VSIAF-Nota de Ingreso Nº #{@note_entry.id}",
               disposition: 'attachment',
               template: 'note_entries/show.html.haml',
               layout: 'pdf.html',
               page_size: 'Letter',
               margin: { top: 15, bottom: 20, left: 20, right: 15 },
               header: { html: { template: 'shared/header.pdf.haml' } },
               footer: { html: { template: 'shared/footer.pdf.haml' } }
      end
    end
  end

  # GET /note_entries/new
  def new
    @note_entry = NoteEntry.new
  end

  # GET /note_entries/1/edit
  def edit
    render 'new'
  end

  # POST /note_entries
  def create
    @note_entry = NoteEntry.new(note_entry_params)
    @note_entry.supplier_id = Supplier.get_id(params[:note_entry][:supplier_id])
    @note_entry.user_id = current_user.id
    @note_entry.save
  end

  # PATCH/PUT /note_entries/1
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
