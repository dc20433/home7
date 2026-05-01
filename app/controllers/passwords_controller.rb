class PasswordsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]

  # Remove the rate_limit line temporarily to see if it's interfering,
  # or ensure it's below allow_unauthenticated_access

  before_action :set_user, only: %i[ edit update ]
  before_action :require_authentication

  def new
  end

  def create
    # Use the column name 'email' to match your User model
    if user = User.find_by(email: params[:email])
      PasswordsMailer.reset(user).deliver_later
      redirect_to new_session_path, notice: "Password reset instructions sent."
    else
      flash.now[:alert] = "Email not found."
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  # app/controllers/passwords_controller.rb
  def update
    # Use Current.user since they are logged in with 'temp123'
    if Current.user.update(params.require(:user).permit(:password, :password_confirmation).merge(activated: true))
      # Redirect to root_path where your RegisController#index logic
      # will then zip them to the signature form
      redirect_to root_path, notice: "Account activated! You can now sign your forms."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private
  def set_user
    if authenticated?
      @user = Current.user
    else
      @user = User.find_by_password_reset_token!(params[:token])
    end
  rescue ActiveSupport::MessageVerifier::InvalidSignature
    redirect_to new_password_path, alert: "Password reset link is invalid or has expired."
  end

  def password_params
    params.require(:user).permit(:password, :password_confirmation, :password_challenge)
  end
end
