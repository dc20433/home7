class ApplicationController < ActionController::Base
  include Authentication
  include Pagy::Backend
  before_action :resume_session
  before_action :check_patient_activation
  before_action :set_session_timestamp
  before_action :ensure_staff_only

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

  # app/controllers/application_controller.rb
  def check_patient_activation
    return unless authenticated?

    # The bouncer now looks at the column you just created
    if Current.user.patient? && !Current.user.activated?
      unless %w[passwords sessions].include?(controller_name)
        redirect_to edit_authenticated_password_path, alert: "Activation required." and return
      end
    end
  end

  def ensure_staff_only
    return unless authenticated?

    # 1. Staff can go anywhere
    return if Current.user.manager? || Current.user.admin?

    # 2. Allow patients ONLY in these controllers
    allowed_controllers = %w[sites patients sessions passwords]

    unless allowed_controllers.include?(controller_name)
      # If a patient tries to go to /regis or /charts, push them to the home page
      redirect_to root_path, alert: "Access restricted." and return
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
