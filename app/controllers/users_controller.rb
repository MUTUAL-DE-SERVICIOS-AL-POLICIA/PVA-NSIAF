class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy, :change_status]

  # GET /users
  # GET /users.json
  def index
    @users = User.all
  end

  # GET /users/1
  # GET /users/1.json
  def show
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
<<<<<<< HEAD
        format.html { redirect_to @user, notice: 'El usuario fue creado con éxito.' }
=======
        format.html { redirect_to @user, notice: t('general.created', model: User.model_name.human) }
>>>>>>> 1c200832eecbeab36d9b31cf4ed6eadea3f8d1e0
        format.json { render action: 'show', status: :created, location: @user }
      else
        format.html { render action: 'new' }
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
<<<<<<< HEAD
        format.html { redirect_to @user, notice: 'El usuario fue actualizado con éxito.' }
=======
        format.html { redirect_to @user, notice: t('general.updated', model: User.model_name.human) }
>>>>>>> 1c200832eecbeab36d9b31cf4ed6eadea3f8d1e0
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
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

  ##
  # GET /users/dbf
  # Muestra el formulario para poder seleccionar un archivo *.dbf y luego proceder
  # a la importación de los datos de Usuarios desde el archivo *.dbf
  def dbf
  end

  ##
  # POST /users/import
  # Importa los datos del archivo DBF dentro de la tabla usuarios.
  def import
    inserted, nils = User.import_dbf(params[:dbf])
    redirect_to :back, notice: "#{inserted + nils} total registros. #{inserted} registros insertados. #{nils} registros nulos."
  end

  def change_status
    @user.change_status
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:code, :name, :title, :ci, :username, :email, :password, :password_confirmation, :phone, :mobile)
    end
end
