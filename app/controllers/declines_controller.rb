class DeclinesController < ApplicationController
  before_action :set_decline, only: [:show, :edit, :update, :destroy]

  # GET /declines
  def index
    @declines = Decline.all
  end

  # GET /declines/1
  def show
  end

  # GET /declines/new
  def new
    @decline = Decline.new
  end

  # GET /declines/1/edit
  def edit
  end

  # POST /declines
  def create
    @decline = Decline.new(decline_params)

    if @decline.save
      redirect_to @decline, notice: 'Decline was successfully created.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /declines/1
  def update
    if @decline.update(decline_params)
      redirect_to @decline, notice: 'Decline was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /declines/1
  def destroy
    @decline.destroy
    redirect_to declines_url, notice: 'Decline was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_decline
      @decline = Decline.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def decline_params
      params.require(:decline).permit(:asset_code, :account_code, :auxiliary_code, :department_code, :user_code, :description, :reason, :user_id)
    end
end
