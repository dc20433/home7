require_relative '../pdfs/patient_directory_pdf'

class RegisController < ApplicationController
  allow_unauthenticated_access only: %i[ index ]
  
  before_action :set_regi, only: %i[ show edit update destroy signup_patient ]
  before_action :require_management_access, only: %i[ show edit update destroy signup_patient ]
  skip_before_action :ensure_staff_only, only: [ :index ]

  def index
    # DEBUG: This will show in your terminal exactly what the app sees
    if Current.user
    end
  
    # 1. Patient Redirect Loop Protection
    if Current.user&.role.to_s == "patient"
      @regi = Regi.find_by(id: Current.user.regi_id)
      
      if @regi
        # Force the redirect to the patient's specific record
        redirect_to route_for_user(Current.user) and return
      else
        # If no link exists, don't show the index!
        reset_session
        redirect_to new_session_path, alert: "No clinical record linked." and return
      end
    end

    # 2. Manager View (Ransack + Pagy)
    @q = Regi.ransack(params[:q])
    results = @q.result.order(last_name: :asc).includes(:user, :patients)

    if params[:q].blank? && params[:letter].present? && params[:letter] != "All"
      results = results.where("last_name ILIKE ?", "#{params[:letter]}%")
    end

    respond_to do |format|
      format.html do
        if params[:print] == "true"
          @regis = results
          @pagy = nil
        else
          @pagy, @regis = pagy(results)
        end
      end
      format.pdf do
        pdf = PatientDirectoryPdf.new(results, "Full Patient List")
        send_data pdf.render,
          filename: "Patient_Directory_#{Date.today}.pdf",
          type: 'application/pdf',
          disposition: 'inline'
      end
    end
  end

  def new
    @regi = Regi.new
  end

  # PATCH /regis/:id/signup_patient
  def signup_patient
    @regi = Regi.find(params[:id])

    # Resolve the email of the active logging administrator
    creator_email = active_manager_email

    @user = User.new(
      email: "#{@regi.last_name}#{@regi.first_name}#{@regi.dob.strftime('%m')}".downcase.gsub(/\s+/, ""),
      password: "temp123",
      password_confirmation: "temp123",
      role: "patient",
      created_by: creator_email, # Automatically logs the active administrator's email safely
      regi_id: @regi.id # Essential: Links the new User record back to this registration
    )

    if @user.save
      # Glue: Associate the registration with the user, and change status to :issued
      @regi.update(user_id: @user.id, status: :issued)
      redirect_to regis_path, notice: "Access issued! Login ID: #{@regi.id}"
    else
      redirect_to regis_path, alert: "User creation failed: #{@user.errors.full_messages.to_sentence}"
    end
  end
  
  # DELETE /regis/:id/destroy_patient_user
  def destroy_patient_user
    @regi = Regi.find(params[:id])
  
    # 1. Generate the expected email to find potential orphans
    prefix = "#{@regi.last_name}#{@regi.first_name}#{@regi.dob.strftime('%m')}".downcase.gsub(/\s+/, "")
    email_to_clean = "#{prefix}"
  
    # 2. Find the user via the association OR the email
    user = @regi.user || User.find_by(email: email_to_clean)
  
    if user
      user.destroy
      # Reset both user association and status back to signup
      @regi.update(user_id: nil, status: :signup)
      redirect_to regis_path, notice: "Login ID #{email_to_clean} deleted. You can now recycle this ID."
    else
      redirect_to regis_path, alert: "No login found for #{email_to_clean}."
    end
  end

  def create
    @regi = Regi.new(regi_params)
    if @regi.save
      redirect_to regis_path, notice: "New Patient Registered..."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @regi.update(regi_params)
      redirect_to regis_path, notice: "Patient Registration updated..."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @regi = Regi.find(params[:id])
    @regi.destroy
    redirect_to regis_path, status: :see_other, notice: "Patient record and access removed."
  end

  # POST /regis/:id/issue_access
  def issue_access
    @regi = Regi.find(params[:id])
    
    dob_m = @regi.dob&.strftime('%m') || "00"
    login_handle = "#{@regi.last_name}#{@regi.first_name}#{dob_m}".downcase.gsub(/\s+/, "")
    login_email = "#{login_handle}"
  
    user = User.find_or_initialize_by(regi_id: @regi.id)
    user.assign_attributes(
      email: login_email,
      password: "temp123",
      password_confirmation: "temp123",
      role: "patient",
      created_by: active_manager_email # Track the exact manager who issued this access safely
    )
  
    if user.save && @regi.update(status: :issued)
      redirect_back fallback_location: regis_path, notice: "Access Issued: #{login_email}"
    else
      redirect_back fallback_location: regis_path, alert: "Error: #{user.errors.full_messages.to_sentence}"
    end
  end
  
  # POST /regis/:id/revoke_access
  def revoke_access
    @regi = Regi.find(params[:id])
    user = User.find_by(regi_id: @regi.id)
    
    if user&.destroy && @regi.update(status: :signup)
      redirect_back fallback_location: regis_path, notice: "Access revoked."
    else
      redirect_back fallback_location: regis_path, alert: "Could not find user to revoke."
    end
  end

  private

  # Failsafe helper to resolve the active administrator's email across Rails 8 environments
  def active_manager_email
    # 1. Try Current.user (Cookie-based session attributes delegation)
    if defined?(Current) && Current.user.present?
      return Current.user.email if Current.user.respond_to?(:email) && Current.user.email.present?
    end

    # 2. Try the classic controller current_user helper method
    if respond_to?(:current_user) && current_user.present?
      return current_user.email if current_user.respond_to?(:email) && current_user.email.present?
    end

    # 3. Direct session lookup as a failsafe backstop
    if session[:user_id].present?
      u = User.find_by(id: session[:user_id])
      return u.email if u&.respond_to?(:email) && u.email.present?
    end

    # 4. Global fallback
    "jz2043@yahoo.com"
  end

  def set_regi
    @regi = Regi.find(params[:id])
  end

  def regi_params
    params.require(:regi).permit(:last_name, :first_name, :init, :gender, :dob, :p_name)
  end
end