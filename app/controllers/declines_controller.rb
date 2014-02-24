class DeclinesController < ApplicationController
  load_and_authorize_resource

  # GET /declines
  def index
    respond_to do |format|
      format.html { render '/shared/index' }
      format.json { render json: DeclinesDatatable.new(view_context) }
    end
  end
end
