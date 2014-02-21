class SessionsController < Devise::SessionsController
  include SimpleCaptcha::ControllerHelpers

  after_action :session_log, only: [:create]
  before_action :session_log, only: [:destroy]

  layout 'login'

  def create
    if simple_captcha_valid?
      super
    else
      sign_out
      self.resource = resource_class.new
      flash[:alert] = "Captcha incorrecto, intente una vez más."
      respond_with_navigational(resource) { render :new }
    end
  end

  private

  def session_log
    action = action_name == 'destroy' ? 'logout' : 'login'
    current_user.register_log(action) if user_signed_in?
  end
end
