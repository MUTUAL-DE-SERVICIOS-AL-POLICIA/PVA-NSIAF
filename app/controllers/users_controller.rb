class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy, :change_status]

  # GET /users
  # GET /users.json
  def index
    respond_to do |format|
      format.html { render '/shared/index' }
      format.json { render json: UsersDatatable.new(view_context) }
    end
  end

  # GET /users/1
  # GET /users/1.json
  def show
  end

  # GET /users/new
  def new
    @user = User.new
    respond_to do |format|
      format.html { render 'form' }
    end
  end

  # GET /users/1/edit
  def edit
    respond_to do |format|
      format.html { render 'form' }
    end
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: t('general.created', model: User.model_name.human) }
        format.json { render action: 'show', status: :created, location: @user }
      else
        format.html { render action: 'form' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    if params[:user][:password].blank?
      params[:user].delete("password")
      params[:user].delete("password_confirmation")
    end

    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: t('general.updated', model: User.model_name.human) }
        format.json { head :no_content }
      else
        format.html { render action: 'form' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: t('general.destroy', name: @user.name) }
      format.json { head :no_content }
    end
  end

  def change_status
    @user.change_status
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:code, :name, :title, :ci, :username, :email, :password, :password_confirmation, :phone, :mobile, :department_id)
    end
end
