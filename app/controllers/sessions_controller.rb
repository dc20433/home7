class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create destroy ]

  def new
  end

  def create
    if user = User.authenticate_by(params.permit(:email, :password))
      # 1. Account Status Check (with safety for database resets)
      if user.respond_to?(:is_active) && !user.is_active
        redirect_to login_path, alert: "This account has been deactivated." and return
      end

      # 2. Start the Rails 8 Session
      start_new_session_for user 

      # 3. Update tracking columns (using update_columns to skip validations)
      # These columns are used for your Overviews usage logs
      user.update_columns(
        last_sign_in_at: user.current_sign_in_at,
        current_sign_in_at: Time.current,
        sign_in_count: (user.sign_in_count || 0) + 1,
        current_sign_in_ip: request.remote_ip
      )

      redirect_to root_path, notice: "Logged in successfully!" and return
    else
      flash.now[:alert] = "Invalid email or password."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    # 1. Safely update timestamp if column exists
    if current_user && current_user.respond_to?(:last_sign_out_at)
      current_user.update_columns(last_sign_out_at: Time.current)
    end

    # 2. Kill the session. 
    # IMPORTANT: In your app, this method ALREADY redirects to root_path.
    terminate_session 
  end
end