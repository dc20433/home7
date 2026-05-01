class PatientsController < ApplicationController
  before_action :set_regi
  before_action :set_patient, only: [ :show, :edit, :update, :handoff_to_patient ]
  before_action :ensure_password_is_changed, if: -> { Current.user&.patient? }

  def index
    @regi = Regi.find(params[:regi_id])

    # --- 1. PATIENT TRIAGE ---
    if Current.user.patient?
      # Find the most recent record based on visit date
      @latest_patient = @regi.patients.order(v_date: :desc).first

      if @latest_patient
        # Land them on the REVIEW (show) page
        redirect_to regi_patient_path(@regi, @latest_patient) and return
      else
        # Brand new patient? Land them on the NEW form
        redirect_to new_regi_patient_path(@regi) and return
      end
    end

    # --- 2. MANAGER VIEW ---
    # If the code reaches this point, the user is NOT a patient.
    # We show the full history list for the registration.
    @patients = @regi.patients.order(v_date: :desc)
  end

  def show
    @regi = Regi.find(params[:regi_id]) # THIS LINE IS CRITICAL
    @patient = @regi.patients.find(params[:id])
  end

  def no_changes
    # Just renders the view
  end

  def new
    @regi = Regi.find(params[:regi_id])

    if @regi.patients.any?
      # 1. Duplicate the medical history from the last visit
      @patient = @regi.patients.order(v_date: :asc).last.dup

      # 2. CRITICAL: Wipe the signature so the View knows to show the Pad
      @patient.signature = nil
      @patient.v_date = Date.today
    else
      # First time visit
      @patient = @regi.patients.build(v_date: Date.today)
    end
  end

  def edit
    # SECURITY: Replaced .patient? with .respond_to? to prevent NoMethodError
    if Current.user.respond_to?(:patient_id) && Current.user.patient_id.present?
      if Current.user.patient_id != @patient.id
        redirect_to root_path, alert: "You do not have permission to edit this record."
      end
    end
  end

  def create
    @regi = Regi.find(params[:regi_id])
    @patient = @regi.patients.build(patient_params)

    if Current.user&.manager? || Current.user&.admin?
      @patient.skip_patient_validation = true
    else
      if params[:patient][:patient_consent] != "true"
        @patient.errors.add(:patient_consent, "must be accepted to proceed")
      end
    end

    if @patient.save
      if Current.user&.manager? || Current.user&.admin?
        redirect_to regi_patients_path(@regi), notice: "Record saved."
      else
        # Redirect to your existing exit page
        redirect_to sites_thank_you_path, notice: "Thank you for your submission."
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @regi = Regi.find(params[:regi_id])
    @patient = @regi.patients.find(params[:id])

    # --- 1. Check if "No Consent" button was clicked ---
    if params[:no_consent_exit] == "true"
      @patient.assign_attributes(patient_params)
      @patient.patient_consent = false
      @patient.signature = nil
      @patient.skip_patient_validation = true

      if @patient.save(validate: false)
        # Redirect to the specific No Consent landing page
        redirect_to no_consent_exit_page_path, notice: "Selection recorded: Consent declined."
      else
        render :edit, status: :unprocessable_entity
      end

    # --- 2. Standard Logic for "Submit Signed Consent" ---
    elsif @patient.update(patient_params)
      if Current.user.patient?
        redirect_to sites_thank_you_path, notice: "Thank you for your submission."
      else
        # Manager/Admin lands back at the patient history list
        redirect_to regi_patients_path(@regi), notice: "Record updated successfully."
      end
    else
      # Handle validation failures (e.g., if a manager missed a field)
      render :edit, status: :unprocessable_entity
    end
  end

  def handoff_to_patient
    @patient = Patient.find(params[:id])
    session[:manager_return_to] = request.referrer

    # Ensure we have a user to hand off to
    if @patient.regi.user.present?
      reset_session
      redirect_to login_path(email: @patient.regi.user.email), notice: "Please hand the device to the patient."
    else
      redirect_to edit_regi_patient_path(@regi, @patient), alert: "No user account associated with this patient."
    end
  end

  def destroy
    @regi = Regi.find(params[:regi_id])
    @patient = @regi.patients.find(params[:id])

    if @patient.destroy
      redirect_to regi_patients_path(@regi), notice: "Visit record was successfully deleted.", status: :see_other
    else
      redirect_to regi_patients_path(@regi), alert: "Record could not be deleted."
    end
  end

  private

  def set_regi
    @regi = Regi.find(params[:regi_id])
  end

  def set_patient
    @patient = @regi.patients.find(params[:id])
  end

  def ensure_password_is_changed
    if Current.user.authenticate("temp123")
      # Using the 'as: :authenticated_password' helper name
      redirect_to edit_authenticated_password_path, alert: "Please set a private password to continue."
    end
  end
  # app/controllers/patients_controller.rb

  def patient_params
    # Ensure signature and consent are permitted
    params.require(:patient).permit(
      :v_date, :street, :city, :state, :zip,
      :cell, :home, :work, :email, :height,
      :weight, :m_stat, :occup, :company,
      :referred, :com1, :com2, :com3,
      :d_onset, :pain_scale, :diag_given,
      :aq_b4, :o_dis, :last_prd, :preg,
      :preg_wks, :signed_at, :signature,
      :signature_verified_by_patient,
      :patient_consent, di_list: []
    )
  end
end
