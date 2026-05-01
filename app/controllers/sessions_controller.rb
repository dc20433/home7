class SessionsController < ApplicationController
  skip_before_action :resume_session, only: :destroy
  skip_before_action :check_patient_activation, only: :destroy
  skip_before_action :set_session_timestamp, only: :destroy

  allow_unauthenticated_access only: %i[ new create ]

  def new
  end

  def create
    login_id = params[:email]

    if login_id.present? && !login_id.include?("@")
      login_id = params[:email].to_s.downcase.strip
    end

    if user = User.authenticate_by(email: login_id, password: params[:password])
      if user.respond_to?(:is_active) && !user.is_active
        redirect_to new_session_path, alert: "This account has been deactivated." and return
      end

      start_new_session_for user

      user.update_columns(
        last_sign_in_at: user.current_sign_in_at,
        current_sign_in_at: Time.current,
        sign_in_count: (user.sign_in_count || 0) + 1,
        current_sign_in_ip: request.remote_ip
      )

      # --- START REDIRECT LOGIC ---
      if user.role == "patient"
        regi = Regi.find_by(user_id: user.id)

        if regi
          # Find the latest patient record associated with this registration
          patient = regi.patients.last

          if patient
            # 1. Form exists: Go to Show view (where Update/No Update choices live)
            redirect_to regi_patient_path(regi, patient), notice: "Welcome back!"
          else
            # 2. No patient record yet: Go to the 'new' info flow
            redirect_to new_regi_patient_path(regi), notice: "Please complete your information."
          end
        else
          redirect_to root_path, alert: "Registration record not found."
        end
      else
        redirect_to root_path, notice: "Logged in successfully!"
      end
      # --- END REDIRECT LOGIC ---

    else
      flash.now[:alert] = "Invalid username/email or password."
      render :new, status: :unprocessable_entity
    end
  end # This closes 'def create'

  # app/controllers/sessions_controller.rb
  def destroy
    terminate_session
    # If terminate_session already redirects (standard in Rails 8 auth),
    # any code after it will cause the DoubleRenderError unless we stop.
    return if performed?

    redirect_to new_session_path, status: :see_other
  end
end
