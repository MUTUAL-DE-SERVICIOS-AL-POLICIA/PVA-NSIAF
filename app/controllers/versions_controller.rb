class VersionsController < ApplicationController
  load_and_authorize_resource

  def index
    respond_to do |format|
      format.html
      format.json { render json: VersionsDatatable.new(view_context) }
    end
  end
end
