class ApplicationController < ActionController::Base
  before_action :check_session_timeout
  include Authentication

  private

  def check_session_timeout
    return unless authenticated?

    # Check if the last activity was more than 30 minutes ago
    if session[:last_active_at] && Time.zone.parse(session[:last_active_at]) < 30.minutes.ago
      terminate_session
      redirect_to new_session_path, alert: "Your session has expired due to inactivity."
    else
      # Update the timestamp for every valid interaction
      session[:last_active_at] = Time.current
    end
  end
end
