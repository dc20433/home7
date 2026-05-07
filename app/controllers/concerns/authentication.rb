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

  def route_for_user(user, password_used = nil)
    # Convert role to string to avoid Enum/Class naming conflicts
    user_role = user.role.to_s.downcase

    if user_role == "patient"
      # Find the linked registration record using the regi_id we added to Users
      regi = Regi.find_by(id: user.regi_id)
      # Check if this registration already has any patient forms filled out
      patient = regi&.patients&.last

      if password_used == "temp123"
        # First stop: Force password change
        "/password/edit"
      elsif regi && patient
        # Second stop: If a form exists, go to the show page
        regi_patient_path(regi, patient)
      elsif regi
        # Third stop: If no form exists, go to the NEW form page
        new_regi_patient_path(regi)
      else
        # Final safety fallback to root
        root_path
      end
    else
      # Admins, Managers, and Staff go to the main index
      regis_path
    end
  end

  private

  def authenticated_user
    user = Current.session&.user
    if user && user.respond_to?(:is_active) && !user.is_active
      terminate_session
      nil
    else
      user
    end
  end

  def authenticated?
    Current.user.present?
  end

  def require_authentication
    resume_session || (request_authentication unless performed?)
  end

  def resume_session
    session = find_session_by_cookie
    return nil unless session

    if session.updated_at < 20.minutes.ago
      terminate_session
      return nil
    end

    session.touch
    Current.session = session
  end

  # (DELETE THE SECOND ROUTE_FOR_USER DEFINITION THAT WAS HERE)

  def start_new_session_for(user)
    user.sessions.create!(user_agent: request.user_agent, ip_address: request.remote_ip).tap do |session|
      Current.session = session
      cookies.signed.permanent[:session_id] = { value: session.id, httponly: true, same_site: :lax }
    end
  end

  def terminate_session
    Current.session&.destroy
    cookies.delete(:session_id)
    redirect_to root_path, status: :see_other, alert: "Session expired or logged out." and return
  end

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
