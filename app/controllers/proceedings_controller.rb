class ProceedingsController < ApplicationController
  before_action :set_proceeding, only: [:show, :edit, :update, :destroy]

  # GET /proceedings
  def index
    @proceedings = Proceeding.all
  end

  # GET /proceedings/1
  def show
  end

  # GET /proceedings/new
  def new
    @proceeding = Proceeding.new
  end

  # GET /proceedings/1/edit
  def edit
  end

  # POST /proceedings
  def create
    @proceeding = Proceeding.new(proceeding_params)

    if @proceeding.save
      redirect_to @proceeding, notice: 'Proceeding was successfully created.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /proceedings/1
  def update
    if @proceeding.update(proceeding_params)
      redirect_to @proceeding, notice: 'Proceeding was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /proceedings/1
  def destroy
    @proceeding.destroy
    redirect_to proceedings_url, notice: 'Proceeding was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_proceeding
      @proceeding = Proceeding.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def proceeding_params
      params.require(:proceeding).permit(:user_id, :admin_id, :proceeding_type)
    end
end
