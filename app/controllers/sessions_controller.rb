class SessionsController < Devise::SessionsController
  include SimpleCaptcha::ControllerHelpers

  before_action :session_log, only: [:create, :destroy]

  layout 'login'

  def create
    if simple_captcha_valid?
      super
    else
      self.resource = resource_class.new(sign_in_params)
      clean_up_passwords(resource)
      sign_in_and_redirect(resource_name, resource)
    end
  end

  private

  def session_log
    action = action_name == 'destroy' ? 'logout' : 'login'
    current_user.register_log(action) if current_user.present?
  end
end
