class WelcomeController < ApplicationController
  def index
    authorize! :index, :welcome
  end
end