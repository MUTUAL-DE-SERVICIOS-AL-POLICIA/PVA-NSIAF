class KardexPricesController < ApplicationController
  before_action :set_kardex_price, only: [:show, :edit, :update, :destroy]

  # GET /kardex_prices
  def index
    @kardex_prices = KardexPrice.all
  end

  # GET /kardex_prices/1
  def show
  end

  # GET /kardex_prices/new
  def new
    @kardex_price = KardexPrice.new
  end

  # GET /kardex_prices/1/edit
  def edit
  end

  # POST /kardex_prices
  def create
    @kardex_price = KardexPrice.new(kardex_price_params)

    if @kardex_price.save
      redirect_to @kardex_price, notice: 'Kardex price was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /kardex_prices/1
  def update
    if @kardex_price.update(kardex_price_params)
      redirect_to @kardex_price, notice: 'Kardex price was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /kardex_prices/1
  def destroy
    @kardex_price.destroy
    redirect_to kardex_prices_url, notice: 'Kardex price was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_kardex_price
      @kardex_price = KardexPrice.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def kardex_price_params
      params.require(:kardex_price).permit(:input_quantities, :output_quantities, :balance_quantities, :unit_cost, :input_amount, :output_amount, :balance_amount, :kardex_id)
    end
end
