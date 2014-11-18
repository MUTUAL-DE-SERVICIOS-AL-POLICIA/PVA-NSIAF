class UsersController < ApplicationController
  load_and_authorize_resource
  before_action :set_user, only: [:show, :edit, :update, :change_status, :csv, :pdf, :historical]

  # GET /users
  # GET /users.json
  def index
    format_to('users', UsersDatatable)
  end

  # GET /users/1
  # GET /users/1.json
  def show
    @assets = @user.assets
    respond_to do |format|
      format.html
      format.json { render json: @user, only: [:id, :name, :title] }
    end
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
        format.html { redirect_to users_url, notice: t('general.created', model: User.model_name.human) }
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
        list_url = @user.id == current_user.id ? @user : users_url
        format.html { redirect_to list_url, notice: t('general.updated', model: User.model_name.human) }
        format.json { head :no_content }
      else
        format.html { render action: 'form' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def change_status
    @user.change_status unless @user.verify_assignment
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  def welcome
    render 'shared/welcome'
  end

  def download
    @assets = @user.assets
    filename = @user.name.parameterize || 'activos'
    respond_to do |format|
      format.html { render nothing: true }
      format.csv do
        send_data @assets.to_csv,
          filename: "#{filename}.csv",
          type: 'text/csv'
      end
      format.pdf do
        render pdf: filename,
               disposition: 'attachment',
               layout: 'pdf.html',
               page_size: 'Letter',
               margin: { top: 15, bottom: 20, left: 15, right: 15 },
               header: { html: { template: 'shared/header.pdf.haml' } },
               footer: { html: { template: 'shared/footer.pdf.haml' } }
      end
    end
  end

  def historical
    assets = Asset.historical_assets(@user)
    respond_to do |format|
      format.json { render json: view_context.selected_assets_json(assets) }
    end
  end

  def autocomplete
    @users = User.search_user(params[:q])
    respond_to do |format|
      format.json { render json: @users.map { |s| { id: s.id, name: s.name, username: s.username, role: s.role } } }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      if current_user.is_super_admin?
        params.require(:user).permit(:name, :username, :role, :password, :password_confirmation)
      else
        params.require(:user).permit(:code, :name, :title, :ci, :username, :email, :password, :password_confirmation, :phone, :mobile, :department_id)
      end
    end


end
