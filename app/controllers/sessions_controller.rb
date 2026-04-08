class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]
  #rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_path, alert: "Try again later." }

  def new
  end

  def create
    if user = User.authenticate_by(params.permit(:email, :password))
      start_new_session_for user
      # Force a full page reload to ensure roles/UI refresh correctly
      redirect_to root_path, status: :see_other, notice: "Logged in!"
    else
      redirect_to new_session_path, alert: "Try again."
    end
  end # <--- This closes 'create'

  def destroy
    terminate_session
    # Force a full page reload to clear the cache for different roles
    redirect_to new_session_path, status: :see_other, notice: "Signed out!"
  end # <--- This closes 'destroy'

end # <--- This closes 'class SessionsController'