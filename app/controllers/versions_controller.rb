class VersionsController < ApplicationController
  load_and_authorize_resource

  def index
    format_to('versions', VersionsDatatable, ['id', 'item_id', 'created_at', 'event', 'whodunnit', 'item_type'])
  end
end
