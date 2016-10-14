class SegurosController < ApplicationController
  before_action :set_seguro, only: [:show, :edit, :update, :destroy]

  # GET /seguros
  # GET /seguros.json
  def index
    @seguros = Seguro.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @seguros }
    end
  end

  # GET /seguros/1
  # GET /seguros/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @seguro }
    end
  end

  # GET /seguros/new
  def new
    @seguro = Seguro.new
  end

  # GET /seguros/1/edit
  def edit
  end

  # POST /seguros
  # POST /seguros.json
  def create
    @seguro = Seguro.new(seguro_params)

    respond_to do |format|
      if @seguro.save
        format.html { redirect_to @seguro, notice: 'Seguro was successfully created.' }
        format.json { render json: @seguro, status: :created }
      else
        format.html { render action: 'new' }
        format.json { render json: @seguro.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /seguros/1
  # PATCH/PUT /seguros/1.json
  def update
    respond_to do |format|
      if @seguro.update(seguro_params)
        format.html { redirect_to @seguro, notice: 'Seguro was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @seguro.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /seguros/1
  # DELETE /seguros/1.json
  def destroy
    @seguro.destroy
    respond_to do |format|
      format.html { redirect_to seguros_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_seguro
      @seguro = Seguro.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def seguro_params
      params.require(:seguro).permit(:supplier, :user, :numero_contrato, :factura_numero, :factura_autorizacion, :factura_fecha, :fecha_inicio_vigencia, :fecha_fin_vigencia, :baja_logica)
    end
end
