class AuxiliariesController < ApplicationController
  before_action :set_auxiliary, only: [:show, :edit, :update, :destroy]

  # GET /auxiliaries
  # GET /auxiliaries.json
  def index
    @auxiliaries = Auxiliary.all
  end

  # GET /auxiliaries/1
  # GET /auxiliaries/1.json
  def show
  end

  # GET /auxiliaries/new
  def new
    @auxiliary = Auxiliary.new
  end

  # GET /auxiliaries/1/edit
  def edit
  end

  # POST /auxiliaries
  # POST /auxiliaries.json
  def create
    @auxiliary = Auxiliary.new(auxiliary_params)

    respond_to do |format|
      if @auxiliary.save
        format.html { redirect_to auxiliaries_url, notice: t('general.created', model: Auxiliary.model_name.human) }
        format.json { render action: 'show', status: :created, location: @auxiliary }
      else
        format.html { render action: 'new' }
        format.json { render json: @auxiliary.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /auxiliaries/1
  # PATCH/PUT /auxiliaries/1.json
  def update
    respond_to do |format|
      if @auxiliary.update(auxiliary_params)
        format.html { redirect_to auxiliaries_url, notice: t('general.updated', model: Auxiliary.model_name.human) }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @auxiliary.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /auxiliaries/1
  # DELETE /auxiliaries/1.json
  def destroy
    @auxiliary.destroy
    respond_to do |format|
      format.html { redirect_to auxiliaries_url, notice: t('general.destroy', name: @auxiliary.name) }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_auxiliary
      @auxiliary = Auxiliary.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def auxiliary_params
      params.require(:auxiliary).permit(:code, :name, :account_id, :status)
    end
end
