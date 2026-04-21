class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]
  #rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_path, alert: "Try again later." }

  def new
  end

  def create
    user = User.find_by(email: params[:email])
  
    if user&.authenticate(params[:password])
      start_new_session_for user
      redirect_to regis_path, status: :see_other, notice: "Logged in!"
    else
      flash.now[:alert] = "Invalid email or password"
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    terminate_session
  end
end