class ProceedingsController < ApplicationController
  before_action :set_proceeding, only: [:show, :edit, :update, :destroy]

  # GET /proceedings
  def index
    respond_to do |format|
      format.html { render '/shared/index' }
      format.json { render json: ProceedingsDatatable.new(view_context) }
    end
  end

  # GET /proceedings/1
  def show
    respond_to do |format|
      format.html
      format.pdf do
        render pdf: @proceeding.user_name.to_param || 'ActaDeEntrega',
               disposition: 'attachment',
               template: 'proceedings/show.html.haml',
               show_as_html: params[:debug].present?,
               orientation: 'Portrait',
               layout: 'pdf.html',
               page_size: 'Letter',
               margin: {
                 top: 15,
                 bottom: 15,
                 left: 20,
                 right: 15
               }
      end
    end
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
    @proceeding.admin_id = current_user.id
    respond_to do |format|
      if @proceeding.save
        format.html { redirect_to @proceeding, notice: 'Proceeding was successfully created.' }
        format.js
      else
        format.html { render action: 'new' }
        format.js
      end
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
      params.require(:proceeding).permit(:user_id, { asset_ids: [] }, :proceeding_type)
    end
end
