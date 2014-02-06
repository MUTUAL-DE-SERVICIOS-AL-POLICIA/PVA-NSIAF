class DepartmentsController < ApplicationController
  before_action :set_department, only: [:show, :edit, :update, :destroy, :change_status]

  # GET /departments
  # GET /departments.json
  def index
    respond_to do |format|
      format.html { render '/shared/index' }
      format.json { render json: DepartmentsDatatable.new(view_context) }
    end
  end

  # GET /departments/1
  # GET /departments/1.json
  def show
  end

  # GET /departments/new
  def new
    @department = Department.new
    respond_to do |format|
      format.html { render 'form' }
    end
  end

  # GET /departments/1/edit
  def edit
    respond_to do |format|
      format.html { render 'form' }
    end
  end

  # POST /departments
  # POST /departments.json
  def create
    @department = Department.new(department_params)

    respond_to do |format|
      if @department.save
        format.html { redirect_to departments_url, notice: t('general.created', model:Department.model_name.human) }
        format.json { render action: 'show', status: :created, location: @department }
      else
        format.html { render action: 'form' }
        format.json { render json: @department.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /departments/1
  # PATCH/PUT /departments/1.json
  def update
    respond_to do |format|
      if @department.update(department_params)
        format.html { redirect_to departments_url, notice: t('general.updated', model: Department.model_name.human) }
        format.json { head :no_content }
      else
        format.html { render action: 'form' }
        format.json { render json: @department.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /departments/1
  # DELETE /departments/1.json
  def destroy
    @department.destroy
    respond_to do |format|
      format.html { redirect_to departments_url, notice: t('general.destroy', name: @department.name) }
      format.json { head :no_content }
    end
  end

  def change_status
    @department.change_status
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_department
      @department = Department.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def department_params
      params.require(:department).permit(:code, :name, :status, :building_id)
    end
end
