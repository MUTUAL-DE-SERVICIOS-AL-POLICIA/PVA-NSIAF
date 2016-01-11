class SuppliersController < ApplicationController
  load_and_authorize_resource
  before_action :set_supplier, only: [:show, :edit, :update, :destroy]

  # GET /suppliers
  def index
    format_to('suppliers', SuppliersDatatable)
  end

  # GET /suppliers/1
  def show
  end

  # GET /suppliers/new
  def new
    @supplier = Supplier.new
    render :form
  end

  # GET /suppliers/1/edit
  def edit
    render :form
  end

  # POST /suppliers
  def create
    @supplier = Supplier.new(supplier_params)

    if @supplier.save
      redirect_to suppliers_url, notice: t('general.created', model: Supplier.model_name.human)
    else
      render :form
    end
  end

  # PATCH/PUT /suppliers/1
  def update
    if @supplier.update(supplier_params)
      redirect_to @supplier, notice: 'Supplier was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /suppliers/1
  def destroy
    @supplier.destroy
    redirect_to suppliers_url, notice: 'Supplier was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_supplier
      @supplier = Supplier.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def supplier_params
      params.require(:supplier).permit(:name, :nit, :telefono, :contacto)
    end
end
