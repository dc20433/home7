class ApplicationController < ActionController::Base
  include Authentication
  include Pagy::Backend
  before_action :Current.session.updated_at = Time.current if Current.session

    def current_user
      return @current_user if defined?(@current_user)

      if session[:user_id]
        user = User.find_by(id: session[:user_id])

        # Check if the user exists and is active
        # We use respond_to? to prevent a crash if the column is missing
        if user && user.respond_to?(:is_active) && user.is_active == false
          reset_session
          @current_user = nil
        else
          @current_user = user
        end
      end
      @current_user
    end
end
