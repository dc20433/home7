class SessionsController < ApplicationController
  skip_before_action :resume_session, only: :destroy
  skip_before_action :check_patient_activation, only: :destroy
  skip_before_action :set_session_timestamp, only: :destroy

  allow_unauthenticated_access only: %i[ new create ]

  def new
  end

  def create
    login_id = params[:email].to_s.downcase.strip
  
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
  
      # Use the logic from the Authentication Concern
      # Passing params[:password] to check for "temp123"
      destination = route_for_user(user, params[:password])
      
      redirect_to destination, notice: "Logged in successfully!"
    else
      flash.now[:alert] = "Invalid username/email or password."
      render :new, status: :unprocessable_entity
    end
  end

  # app/controllers/sessions_controller.rb
  def destroy
    terminate_session
    # If terminate_session already redirects (standard in Rails 8 auth),
    # any code after it will cause the DoubleRenderError unless we stop.
    return if performed?

    redirect_to new_session_path, status: :see_other
  end
end
