class PatientsController < ApplicationController
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
    @patient = @regi.patients.build
  end

  # GET regis/1/patients/1/edit
  def edit
  end

  # POST regis/1/patients
  def create
    @patient = @regi.patients.build(patient_params)

    if @patient.save
      redirect_to([@patient.regi, @patient], notice: 'Patient was successfully created.')
    else
      render action: 'new'
    end
  end

  # PUT regis/1/patients/1
  def update
    if @patient.update(patient_params)
      redirect_to([@patient.regi, @patient], notice: 'Patient was successfully updated.')
    else
      render action: 'edit'
    end
  end

  # DELETE regis/1/patients/1
  def destroy
    @patient.destroy

    redirect_to regi_patients_url(@regi)
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
      params.require(:patient).permit(:v_date, :name, :street, :city, :state, :zip, :cell, :home, :work, :email, :height, :weight, :m_stat, :occup, :company, :referred, :comp1, :comp2, :comp3, :d_onset, :pain_scale, :diag_given, :aq_b4, :di_list, :o_dis, :last_prd, :preg, :preg_wks)
    end
end
