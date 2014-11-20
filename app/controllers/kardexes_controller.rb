class KardexesController < ApplicationController
  before_action :set_kardex, only: [:show, :edit, :update, :destroy]

  # GET /kardexes
  def index
    @kardexes = Kardex.all
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
      redirect_to @kardex, notice: 'Kardex was successfully created.'
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
      params.require(:kardex).permit(:kardex_date, :invoice_number, :order_number, :detail, :subarticle_id)
    end
end
