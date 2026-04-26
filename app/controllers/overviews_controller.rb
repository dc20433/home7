class OverviewsController < ApplicationController
  before_action :require_authentication
  # Note: ensure_admin now uses your Current.admin? helper for Rails 8 safety
  before_action :ensure_admin, only: [ :usage_logs, :signup_records, :patient_stats ]

  # ---------------------------------------------------------
  # ADMIN DASHBOARD VIEWS
  # ---------------------------------------------------------

  def usage_logs
    @users = User.all.order(current_sign_in_at: :desc)
  end

  def signup_records
    @signups = Regi.all.order(created_at: :desc)
  end

  def patient_stats
    @total_patients = Regi.count
    @total_male_patients = Regi.where(gender: "Male").count
    @total_female_patients = Regi.where(gender: "Female").count
    @total_charts = Chart.count
    @total_info_records = Patient.count
    @total_filing = Filing.count

    # Averages
    @average_charts_per_patient = @total_patients > 0 ? (@total_charts.to_f / @total_patients).round(1) : 0
    @average_charts_per_day = @total_charts > 0 ? (@total_charts.to_f / (Chart.distinct.count(:t_date))).round(1) : 0
    @average_age = Regi.where("dob IS NOT NULL").average("EXTRACT(YEAR FROM AGE(NOW(), dob))").to_f.round(1)
    @average_male_age = Regi.where(gender: "Male").where("dob IS NOT NULL").average("EXTRACT(YEAR FROM AGE(NOW(), dob))").to_f.round(1)
    @average_female_age = Regi.where(gender: "Female").where("dob IS NOT NULL").average("EXTRACT(YEAR FROM AGE(NOW(), dob))").to_f.round(1)

    # Gender Breakdown
    @male_records = Patient.joins(:regi).where(regis: { gender: "Male" }).count
    @female_records = Patient.joins(:regi).where(regis: { gender: "Female" }).count
    @male_charts = Chart.joins(:regi).where(regis: { gender: "Male" }).count
    @female_charts = Chart.joins(:regi).where(regis: { gender: "Female" }).count
    @male_filing = Filing.joins(:regi).where(regis: { gender: "Male" }).count
    @female_filing = Filing.joins(:regi).where(regis: { gender: "Female" }).count
    @male_charts_per_patient = @total_male_patients > 0 ? (@male_charts.to_f / @total_male_patients).round(1) : 0
    @female_charts_per_patient = @total_female_patients > 0 ? (@female_charts.to_f / @total_female_patients).round(1) : 0
  end

  # ---------------------------------------------------------
  # CLINICAL DATA VIEWS
  # ---------------------------------------------------------

  def chart_date
    @q = Chart.ransack(params[:q])
    results = @q.result.joins(:regi).includes(:regi)

    # PRESERVED: Latest to oldest by default; Older to Newer when searching
    if params[:q].present? || params[:dir] == "asc"
      results = results.reorder("charts.t_date ASC, regis.last_name ASC")
    else
      results = results.reorder("charts.t_date DESC, regis.last_name ASC")
    end

    @pagy, @charts = paginate_or_print(results)
  end

  def chart_name
    @q = Chart.ransack(params[:q])
    results = @q.result.joins(:regi).includes(:regi)
                .order("regis.last_name ASC, regis.first_name ASC, charts.t_date DESC")

    if params[:q].blank? && params[:letter].present? && params[:letter] != "All"
      results = results.where("regis.last_name ILIKE ?", "#{params[:letter]}%")
    end

    @pagy, @charts = paginate_or_print(results)
  end

  def patient_info
    @q = Patient.ransack(params[:q])
    results = @q.result.includes(:regi).order("regis.last_name ASC")

    if params[:letter].present? && params[:letter] != "All"
      results = results.joins(:regi).where("regis.last_name ILIKE ?", "#{params[:letter]}%")
    end

    @pagy, @patients = paginate_or_print(results)
  end

  private

  def ensure_admin
    unless Current.admin?
      redirect_to root_path, alert: "Access denied. Admins only."
    end
  end
end
