class SitesController < ApplicationController
  allow_unauthenticated_access only: :home
  skip_before_action :ensure_staff_only, only: [ :home ]

  def home
    # Only run the redirect logic if the user is truly authenticated 
    # AND the session is not currently being destroyed.
    if authenticated? && !request.fullpath.include?('session')
      if Current.user.patient?
        @regi = Regi.find_by(user_id: Current.user.id)
        redirect_to new_regi_patient_path(@regi) if @regi
      elsif Current.user.manager? || Current.user.admin?
        redirect_to regis_path
      end
    end
    # If not authenticated, the page simply renders the home view normally.
  end

  def no_consent
    # This just renders the view
  end

  def thank_you
    # This just renders app/views/sites/thank_you.html.erb
  end
end
