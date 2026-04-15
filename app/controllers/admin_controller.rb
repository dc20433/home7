class AdminController < ApplicationController
  before_action :resume_session
  before_action :require_admin!

  private

  def require_admin!
    # If they are a Manager or Patient, send them away!
    redirect_to root_path, alert: "Admins only." unless Current.user.admin?
  end
end