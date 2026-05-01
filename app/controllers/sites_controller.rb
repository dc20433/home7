class SitesController < ApplicationController
   skip_before_action :ensure_staff_only, only: [ :home ]

   def home
    # If they are logged in, we can gently nudge them to their dashboard
    if authenticated?
      if Current.user.patient?
        @regi = Regi.find_by(user_id: Current.user.id)
        # Only redirect if they aren't already on their way out
        redirect_to new_regi_patient_path(@regi) if @regi && action_name != "destroy"
      elsif Current.user.manager? || Current.user.admin?
        redirect_to regis_path
      end
    end
  end

  def no_consent
    # This just renders the view
  end

  def thank_you
    # This just renders app/views/sites/thank_you.html.erb
  end
end
