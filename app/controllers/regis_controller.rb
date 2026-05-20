require_relative '../pdfs/patient_directory_pdf'

class RegisController < ApplicationController
  before_action :resume_session
  before_action :require_management_access, only: %i[ show edit update destroy signup_patient ]
  before_action :set_regi, only: %i[ show edit update destroy signup_patient ]
  skip_before_action :ensure_staff_only, only: [ :index ]

  # GET /regis
  # GET /regis.pdf
  def index
    # DEBUG: This will show in your terminal exactly what the app sees
    if Current.user
      Rails.logger.info "LOGGING IN AS: #{Current.user.id} | ROLE: #{Current.user.role.inspect}"
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

    # 2. Manager View (Ransack Query Construction)
    @q = Regi.ransack(params[:q])
    results = @q.result.order(last_name: :asc).includes(:user, :patients)

    # Alphabetical letter filtering
    if params[:letter].present? && params[:letter] != "All"
      results = results.where("regis.last_name ILIKE ?", "#{params[:letter]}%")
    end

    respond_to do |format|
      format.html do
        # Paginate normally unless in print preview mode
        if params[:print] == "true"
          @regis = results
        else
          @pagy, @regis = pagy(results, items: 15)
        end
      end
      format.pdf do
        # Export the full matching dataset, bypassing pagination completely
        pdf = PatientDirectoryPdf.new(results, "Full Patient List")
        send_data pdf.render,
          filename: "Patient_Directory_#{Date.today}.pdf",
          type: 'application/pdf',
          disposition: 'inline'
      end
    end
  end

  # GET /regis/1
  def show
  end

  # GET /regis/new
  def new
    @regi = Regi.new
  end

  # POST /regis
  def create
    @regi = Regi.new(regi_params)
    if @regi.save
      redirect_to regis_path, notice: "Registration successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /regis/1/edit
  def edit
  end

  # PATCH/PUT /regis/1
  def update
    if @regi.update(regi_params)
      redirect_to regis_path, notice: "Registration successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /regis/1
  def destroy
    @regi.destroy
    redirect_to regis_path, notice: "Registration successfully deleted.", status: :see_other
  end

  # POST /regis/1/signup_patient
  def signup_patient
    dob_m = @regi.dob&.strftime('%m') || "00"
    login_handle = "#{@regi.last_name}#{@regi.first_name}#{dob_m}".downcase.gsub(/\s+/, "")
    login_email = "#{login_handle}"
  
    user = User.find_or_initialize_by(regi_id: @regi.id)
    user.assign_attributes(
      email: login_email,
      password: "temp123",
      password_confirmation: "temp123",
      role: "patient" # Use the lowercase string to match the Enum key
    )
  
    if user.save && @regi.update(status: :issued)
      redirect_back fallback_location: regis_path, notice: "Access Issued: #{login_email}"
    else
      redirect_back fallback_location: regis_path, alert: "Error: #{user.errors.full_messages.to_sentence}"
    end
  end
  
  # POST /regis/1/revoke_access
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

  def set_regi
    @regi = Regi.find(params[:id])
  end

  def require_management_access
    # Prevent patients (role "patient") from accessing management views
    if Current.user&.role.to_s == "patient"
      redirect_to root_path, alert: "Unauthorized access."
    end
  end

  def regi_params
    params.require(:regi).permit(:first_name, :last_name, :mi, :dob, :gender, :p_phone)
  end
end