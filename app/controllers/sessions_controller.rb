class SessionsController < Devise::SessionsController
  before_action :session_log, only: [:create, :destroy]

  layout 'login'

  private

  def session_log
    action = action_name == 'destroy' ? 'logout' : 'login'
    current_user.register_log(action) if current_user.present?
  end
end
