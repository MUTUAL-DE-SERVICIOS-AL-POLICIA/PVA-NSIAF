class VersionsController < ApplicationController
  load_and_authorize_resource

  def index
    format_to('versions', VersionsDatatable)
  end
end
