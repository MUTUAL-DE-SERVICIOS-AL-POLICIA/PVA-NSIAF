class DbfController < ApplicationController
  def index
    logger.info params[:model_name]
  end
end
