class ApplicationController < ActionController::Base
  include Authentication
  include Pagy::Backend

  # Fixed the syntax here to be more reliable
  before_action :set_session_timestamp

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

  private

  def set_session_timestamp
    Current.session.update_columns(updated_at: Time.current) if Current.session
  end

  # This is the DRY helper that replaces the "if params[:print]" blocks
  def paginate_or_print(results)
    if params[:print] == "true"
      [ nil, results ]
    else
      pagy(results)
    end
  end
end
