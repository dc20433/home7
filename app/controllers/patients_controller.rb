class PatientsController < ApplicationController
  #before_action :authenticate_user!
  before_action :set_regi
  before_action :set_patient, only: [:show, :edit, :update, :destroy]

  # GET regis/1/patients
  def index
    @patients = @regi.patients
  end

  # GET regis/1/patients/1
  def show
  end

  # GET regis/1/patients/new
  def new
    if defined?(Patient.where(regi_id: params[:regi_id]).last.id)
      @patient = @regi.patients.order('v_date ASC').last.dup
    else
      @patient = @regi.patients.build
    end
  end

  # GET regis/1/patients/1/edit
  # app/controllers/patients_controller.rb
  def edit
    @patient = Patient.find(params[:id])
    
    # SECURITY: If I am a patient, I can ONLY edit my own ID
    if Current.user.patient? && Current.user.patient_id != @patient.id
      redirect_to root_path, alert: "You do not have permission to edit this record."
    end
  end

  # POST regis/1/patients
  def create
    @patient = @regi.patients.build(patient_params)

    if @patient.save
      redirect_to regi_patients_path(@regi), notice:'Patient Record Created...'
      #redirect_to consent_path, notice: "Patient Record Created..."
    else
      render action: 'new'
    end
  end

  # PUT regis/1/patients/1
  def update
    if @patient.update(patient_params)
      redirect_to regi_patients_path(@regi), notice:'Patient Record Updated...'
    else
      render action: 'edit'
    end
  end

  # DELETE regis/1/patients/1
  def destroy
    @patient.destroy
    redirect_to regi_patients_path(@regi), notice: "Patient Record Deleted..."
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_regi
      @regi = Regi.find(params[:regi_id])
    end

    def set_patient
      @patient = @regi.patients.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def patient_params
      params.require(:patient).permit(
        :name, :v_date, :m_stat, :weight, :height, :street, :city, :state, :zip, 
        :cell, :home, :work, :email, :referred, :com1, :com2, :com3, 
        :d_onset, :pain_scale, :diag_given, :aq_b4, :o_dis, :last_prd, 
        :preg, :preg_wks, :regi_id,
        # This line replaces 'di_list:[]' and automatically permits 
        # every key you defined in your Patient model's HEALTH_ISSUES hash
        *Patient::HEALTH_ISSUES.keys
      )
    end
end
