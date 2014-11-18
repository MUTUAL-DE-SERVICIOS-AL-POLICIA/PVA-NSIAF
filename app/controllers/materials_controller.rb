class MaterialsController < ApplicationController
  load_and_authorize_resource
  before_action :set_material, only: [:show, :edit, :update, :change_status]

  # GET /materials
  def index
    format_to('materials', MaterialsDatatable)
  end

  # GET /materials/1
  def show
  end

  # GET /materials/new
  def new
    @material = Material.new
    respond_to do |format|
      format.html { render 'form' }
    end
  end

  # GET /materials/1/edit
  def edit
    respond_to do |format|
      format.html { render 'form' }
    end
  end

  # POST /materials
  def create
    @material = Material.new(material_params)

    respond_to do |format|
      if @material.save
        format.html { redirect_to materials_url, notice: t('general.created', model: Material.model_name.human) }
      else
        format.html { render action: 'form' }
      end
    end
  end

  # PATCH/PUT /materials/1
  def update
    respond_to do |format|
      if @material.update(material_params)
        format.html { redirect_to materials_url, notice: t('general.updated', model: Material.model_name.human) }
      else
        format.html { render action: 'form' }
      end
    end
  end

  def change_status
    @material.change_status unless @material.verify_assignment
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  def reports
    @materials = Material.order("description ASC")
    @articles = Article.order("description ASC")
    @subarticles = Subarticle.order("description ASC")
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_material
      @material = Material.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def material_params
      params.require(:material).permit(:code, :description, :status)
    end
end
