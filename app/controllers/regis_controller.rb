class RegisController < ApplicationController
  before_action :resume_session
  before_action :require_management_access, only: %i[ show edit update destroy signup_patient ]
  before_action :set_regi, only: %i[ show edit update destroy signup_patient ]
  skip_before_action :ensure_staff_only, only: [ :index ]

  def index
    if Current.user&.patient?
      @regi = Regi.find_by(user_id: Current.user.id)
      if @regi
        # Send to signature form if not signed
        redirect_to new_regi_patient_path(@regi) and return unless @regi.patients.any?
      else
        # Safety net: if somehow they have no link, don't show the background image
        reset_session
        redirect_to login_path, alert: "No clinical record linked. Please contact the manager." and return
      end
    end

    # 2. Manager View (Ransack + Pagy)
    @q = Regi.ransack(params[:q])
    results = @q.result.order(last_name: :asc).includes(:user, :patients)

    if params[:q].blank? && params[:letter].present? && params[:letter] != "All"
      results = results.where("last_name ILIKE ?", "#{params[:letter]}%")
    end

    if params[:print] == "true"
      @regis = results
      @pagy = nil
    else
      @pagy, @regis = pagy(results)
    end
  end

  def new
    @regi = Regi.new
  end

  def signup_patient
    @regi = Regi.find(params[:id])

    @user = User.new(
      email: "#{@regi.last_name}#{@regi.first_name}#{@regi.dob.strftime('%m')}".downcase.gsub(/\s+/, "") + "@clinic.local",
      password: "temp123",
      password_confirmation: "temp123",
      role: "patient"
    )

    if @user.save
      # This is the "Glue" that was missing before
      @regi.update_column(:user_id, @user.id)
      redirect_to regis_path, notice: "Access issued! Login ID: #{@regi.id}"
    else
      redirect_to regis_path, alert: "User creation failed."
    end
  end
  def destroy_patient_user
    @regi = Regi.find(params[:id])

    # Find user via the link OR via the calculated email (to catch orphans)
    prefix = "#{@regi.last_name}#{@regi.first_name}#{@regi.dob.strftime('%m')}".downcase.gsub(/\s+/, "")
    email_to_clean = "#{prefix}@local.clinic"
    user = @regi.user || User.find_by(email: email_to_clean)

    if user
      user.destroy
      @regi.update(user_id: nil)
      redirect_to regis_path, notice: "Login deleted. You can now issue a fresh one."
    else
      redirect_to regis_path, alert: "No login found to delete."
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

    # This ensures the associated patient signature and user are cleaned up
    @regi.destroy

    redirect_to regis_path, status: :see_other, notice: "Patient record and access removed."
  end

  private

  def require_management_access
    # Prevent patients (role 0) from accessing staff tools
    unless Current.user&.admin? || Current.user&.manager?
      redirect_to root_path, alert: "Access Denied."
    end
  end

  def set_regi
    @regi = Regi.find(params[:id])
  end

  def regi_params
    params.require(:regi).permit(:last_name, :first_name, :init, :gender, :dob, :p_name)
  end
end
