class DerecognisedController < ApplicationController
  def index
    format_to('assets', AssetsDatatable)
  end
end
