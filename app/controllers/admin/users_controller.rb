class Admin::UsersController < ApplicationController
  before_action :require_authentication
  before_action :ensure_admin
  before_action :set_user, only: [ :edit, :update, :destroy ]

  def index
    @users = User.all.order(created_at: :desc)
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to admin_users_path, notice: "Account created for #{@user.email}."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to admin_users_path, notice: "User updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @user.destroy
    redirect_to admin_users_path, notice: "User deleted."
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    # Permit role and is_active for the SCUD workflow
    params.require(:user).permit(:email, :password, :password_confirmation, :role, :is_active)
  end

  def ensure_admin
  unless Current.admin? # This uses the delegated user check you built
    redirect_to root_path, alert: "Access denied."
  end
end
end
