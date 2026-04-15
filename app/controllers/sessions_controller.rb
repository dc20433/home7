class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]
  #rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_path, alert: "Try again later." }

  def new
  end

  def create
    if user = User.authenticate_by(params.permit(:email, :password))
      start_new_session_for user
      # Force a full page reload to ensure roles/UI refresh correctly
      redirect_to regis_path, status: :see_other, notice: "Logged in!"
    else
      redirect_to new_session_path, alert: "Try again."
    end
  end

  def destroy
    terminate_session
  end
end