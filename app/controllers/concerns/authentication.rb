module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :require_authentication
    helper_method :authenticated?
  end

  class_methods do
    def allow_unauthenticated_access(**options)
      skip_before_action :require_authentication, **options
    end
  end

  private

  # 1. Verification Methods
  def authenticated?
    resume_session
  end

  def require_authentication
    # Logic: Try to resume. If it returns nil (expired or no cookie), 
    # trigger request_authentication unless a redirect already happened.
    resume_session || (request_authentication unless performed?)
  end

  # 2. Session Lifecycle Logic
  def resume_session
    session = find_session_by_cookie
    return nil unless session

    # The 30-minute inactivity check
    if session.updated_at < 20.minutes.ago
      terminate_session
      return nil 
    end

    session.touch # Updates updated_at to reset the 30-minute clock
    Current.session ||= session
  end

  def start_new_session_for(user)
    user.sessions.create!(user_agent: request.user_agent, ip_address: request.remote_ip).tap do |session|
      Current.session = session
      cookies.signed.permanent[:session_id] = { value: session.id, httponly: true, same_site: :lax }
    end
  end

  def terminate_session
    Current.session&.destroy
    cookies.delete(:session_id)
    # Status :see_other is vital for Rails 8 Turbo redirects
    redirect_to new_session_path, status: :see_other, alert: "Session expired or logged out." and return
  end

  # 3. Helper Logic
  def find_session_by_cookie
    Session.find_by(id: cookies.signed[:session_id]) if cookies.signed[:session_id]
  end

  def request_authentication
    session[:return_to_after_authenticating] = request.url
    redirect_to new_session_path
  end

  def after_authentication_url
    session.delete(:return_to_after_authenticating) || root_url
  end
end
