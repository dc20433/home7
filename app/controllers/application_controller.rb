class ApplicationController < ActionController::Base
  include Authentication
  include Pagy::Backend
  before_action :resume_session
  before_action :check_patient_activation
  before_action :set_session_timestamp
  before_action :ensure_staff_only
  before_action :redirect_patients_from_manager_zone

  def current_user
    return @current_user if defined?(@current_user)

    if session[:user_id]
      user = User.find_by(id: session[:user_id])
      if user && user.respond_to?(:is_active) && user.is_active == false
        reset_session
        @current_user = nil
      else
        @current_user = user
      end
    end
    @current_user
  end

  # app/controllers/application_controller.rb
  def require_management_access
    # Only allow manager (1) or admin (2).
    # Specifically excludes user (0) and patient (3).
    unless Current.user&.manager? || Current.user&.admin?
      redirect_to root_path, alert: "Management access required."
    end
  end

  private

  def set_session_timestamp
    Current.session.update_columns(updated_at: Time.current) if Current.session
  end

  def ensure_staff_only
    return unless authenticated?

    # Use .to_s.downcase to match the Enum keys we found ["user", "manager", "admin", "patient"]
    user_role = Current.user.role.to_s.downcase
    return if %w[manager admin].include?(user_role)

    # Strict whitelist for patients
    allowed_controllers = %w[sites patients sessions passwords users]

    unless allowed_controllers.include?(controller_name)
      # If a patient is where they shouldn't be, force them to their route
      redirect_to route_for_user(Current.user), alert: "Access restricted." and return
    end
  end

  def check_patient_activation
    return unless authenticated?

    # If a patient isn't activated, force them to the password/activation page
    # unless they are already on a controller that handles authentication
    if Current.user.role == "patient" && !Current.user.activated?
      unless %w[passwords sessions].include?(controller_name)
        # Using route_for_user here with 'temp123' logic is also an option
        redirect_to edit_user_path(Current.user), alert: "Activation required." and return
      end
    end
  end

  def redirect_patients_from_manager_zone
    # This will print to your 'rails s' window
    puts "Checking Bouncer: User=#{Current.user&.id}, Role=#{Current.user&.role}"

    if authenticated? && Current.user.role.to_s.downcase == "patient"

      # If they are on the manager index (regis) OR the home page (root)
      if controller_name == "regis" || request.path == "/"
        # Use our single source of truth for where they should actually be
        destination = route_for_user(Current.user)

        # If the destination is DIFFERENT from where they are now, move them
        redirect_to destination and return unless request.path == destination
      end
    end
  end

  def paginate_or_print(results)
    if params[:print] == "true"
      [ nil, results ]
    else
      pagy(results)
    end
  end
end
