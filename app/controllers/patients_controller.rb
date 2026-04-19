class PatientsController < ApplicationController
  before_action :set_regi
  before_action :set_patient, only: [:show, :edit, :update, :destroy]

  def index
    @patients = @regi.patients
  end

  def show
  end

  def new
    # Pre-populates 'New' with the last record's data if it exists
    if @regi.patients.any?
      @patient = @regi.patients.order('v_date ASC').last.dup
    else
      @patient = @regi.patients.build
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
    # Strip time from v_date to ensure the 'Upsert' logic finds the right record
    clean_date = patient_params[:v_date].to_date if patient_params[:v_date].present?
  
    # Finds existing record for the same date or initializes a new one
    @patient = @regi.patients.find_or_initialize_by(v_date: clean_date)
    @patient.assign_attributes(patient_params)
  
    if @patient.save
      # Redirect to index (Patient List) as requested
      redirect_to regi_patients_path(@regi), notice: "Record saved."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @patient.update(patient_params)
      redirect_to regi_patients_path(@regi), notice: 'Patient Record Updated.'
    else
      render action: 'edit'
    end
  end

  def destroy
    @patient.destroy
    redirect_to regi_patients_path(@regi), notice: "Patient Record Deleted."
  end

  private

  def set_regi
    @regi = Regi.find(params[:regi_id])
  end

  def set_patient
    @patient = @regi.patients.find(params[:id])
  end

  def patient_params
    # Ensure signature and consent are permitted
    params.require(:patient).permit(
      :v_date, :street, :city, :state, :zip, 
      :cell, :home, :work, :email, :height, 
      :weight, :m_stat, :occup, :company, 
      :referred, :com1, :com2, :com3, 
      :d_onset, :pain_scale, :diag_given, 
      :aq_b4, :o_dis, :last_prd, :preg, 
      :preg_wks, :signed_at, :signature, :patient_consent,
      di_list: []
    )
  end
end