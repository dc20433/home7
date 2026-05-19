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

  # Example: app/controllers/patients_controller.rb
  def show
    # Priority 1: URL Param | Priority 2: Link in User Table
    @regi = Regi.find_by(id: params[:regi_id]) || Regi.find_by(id: current_user.regi_id)
  
    if @regi
      @patient = @regi.patients.first # Or find by params[:id]
    else
      # This is what you see now because current_user.regi_id is currently NULL
      render "no_record_found" 
    end

    respond_to do |format|
      format.html # renders show.html.erb
      format.pdf do
        pdf = PatientRecordPdf.new(@patient)
        send_data pdf.render,
          filename: "Patient_Record_#{@patient.regi.p_name.parameterize}_#{@patient.v_date}.pdf",
          type: 'application/pdf',
          disposition: 'inline' # Opens in browser for immediate printing
      end
    end
  end

  def new
    # Check if a record for today already exists
    @patient = @regi.patients.find_by(v_date: Date.today)

    if @patient
      # If it exists, go to edit mode
      redirect_to edit_regi_patient_path(@regi, @patient) and return
    else
      # If not, create a shell record using the last known demographics
      last_patient = @regi.patients.order(v_date: :desc).first
      
      @patient = @regi.patients.build(
        v_date: Date.today,
        street: last_patient&.street,
        city: last_patient&.city,
        state: last_patient&.state,
        zip: last_patient&.zip,
        cell: last_patient&.cell,
        home: last_patient&.home,
        work: last_patient&.work,
        email: last_patient&.email,
        height: last_patient&.height,
        weight: last_patient&.weight,
        m_stat: last_patient&.m_stat,
        occup: last_patient&.occup,
        referred: last_patient&.referred,
        com1: last_patient&.com1,
        com2: last_patient&.com2,
        com3: last_patient&.com3,
        d_onset: last_patient&.d_onset,
        pain_scale: last_patient&.pain_scale,
        diag_given: last_patient&.diag_given,
        aq_b4: last_patient&.aq_b4,
        di_list: last_patient&.di_list,
        o_dis: last_patient&.o_dis,
        last_prd: last_patient&.last_prd,
        preg: last_patient&.preg,
        preg_wks: last_patient&.preg_wks
      )
      
      # Managers bypass validations to establish the record
      @patient.skip_patient_validation = true if Current.user&.manager? || Current.user&.admin?
      
      if @patient.save(validate: false)
        redirect_to edit_regi_patient_path(@regi, @patient) and return
      else
        # Fallback to standard new form if shell creation fails
        render :new
      end
    end
  end

  def create
    @regi = Regi.find(params[:regi_id])
    
    # Normalize the date to ensure the database find_by works perfectly
    submitted_date = patient_params[:v_date].to_date rescue nil

    # Look for the record. If it exists, we load it. If not, we build a new one.
    @patient = @regi.patients.find_by(v_date: submitted_date) || @regi.patients.build

    # Update the attributes (either on the found record or the new one)
    @patient.assign_attributes(patient_params)

    # --- Your existing logic remains exactly the same ---
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
        redirect_to sites_thank_you_path, notice: "Thank you for your submission."
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

def update
    @regi = Regi.find(params[:regi_id])
    @patient = @regi.patients.find(params[:id])

    # --- NEW GUARD: Prevent updating this record to a date that already has a different record ---
    new_v_date = patient_params[:v_date]
    duplicate = @regi.patients.where(v_date: new_v_date).where.not(id: @patient.id).first

    if duplicate
      flash[:alert] = "A record for #{new_v_date} already exists. You cannot change this record to that date."
      render :edit, status: :unprocessable_entity
      return # Stop execution
    end
    # --- END GUARD ---

    # --- 1. Check if "No Consent" button was clicked ---
    if params[:no_consent_exit] == "true"
      @patient.assign_attributes(patient_params)
      @patient.patient_consent = false
      @patient.signature = nil
      @patient.skip_patient_validation = true

      if @patient.save(validate: false)
        redirect_to no_consent_path, notice: "Selection recorded: Consent declined."
      else
        render :edit, status: :unprocessable_entity
      end

    # --- 2. Standard Logic for "Submit Signed Consent" ---
    elsif @patient.update(patient_params)
      if Current.user.patient?
        redirect_to sites_thank_you_path, notice: "Thank you for your submission."
      else
        redirect_to regi_patients_path(@regi), notice: "Record updated successfully."
      end
    else
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

  def handle_account_activation
    if @regi.user.nil? && @patient.email.present?
      begin
        @regi.create_user!(
          email: @patient.email, password: "temp123", password_confirmation: "temp123", role: "patient"
        )
      rescue ActiveRecord::RecordInvalid
      end
    end
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
      :aq_b4, :o_dis,:hosp, :stress, :exercise,
      :sleep, :tobacco, :alcohol, :last_prd, :preg,
      :preg_wks, :all_meds, :signed_at, :signature,
      :signature1, :rep_name, :vs_date, 
      :signature_verified_by_patient,
      :patient_consent, di_list: []
    )
  end
end
