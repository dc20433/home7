class OverviewsController < ApplicationController
  # This ensures a user is logged in before they can see ANY of these pages
  before_action :require_authentication
  
  # This specifically locks the statistics page to Admins only
  before_action :ensure_admin, only: [:statistics]

  def chart_date
    @q = Chart.ransack(params[:q])
    results = @q.result.includes(:regi).order(t_date: :desc)
    
    if params[:letter].present? && params[:letter] != "All"
      results = results.joins(:regi).where("regis.last_name ILIKE ?", "#{params[:letter]}%")
    end
  
    if params[:print] == "true"
      @charts = results
      @pagy = nil # This is what triggers the error if the view doesn't check for nil
    else
      @pagy, @charts = pagy(results)
    end
  end
  
  def chart_name
    @q = Chart.ransack(params[:q])
    results = @q.result.includes(:regi).order("regis.p_name ASC, charts.t_date DESC")
  
    if params[:q].blank? && params[:letter].present? && params[:letter] != "All"
      results = results.joins(:regi).where("regis.last_name ILIKE ?", "#{params[:letter]}%")
    end

    if params[:print] == "true"
      @charts = results
      @pagy = nil # This is what triggers the error if the view doesn't check for nil
    else  
    @pagy, @charts = pagy(results)
    end
  end
  
  def patient_info
    @q = Patient.ransack(params[:q])
    results = @q.result.includes(:regi).order("regis.last_name ASC")
  
    # Alphabetical letter filter
    if params[:letter].present? && params[:letter] != "All"
      results = results.joins(:regi).where("regis.last_name ILIKE ?", "#{params[:letter]}%")
    end
  
    if params[:print] == "true"
      @patients = results # Ensure this fetches ALL results
      @pagy = nil
    else
      @pagy, @patients = pagy(results)
    end
  end

  def statistics
    return if performed?
    @total_patients = Regi.count
    @total_male_patients = Regi.where(gender: "Male").count
    @total_female_patients = Regi.where(gender: "Female").count
    @total_other_patients = @total_patients - @total_male_patients - @total_female_patients
    @total_charts = Chart.count
    @total_info_records = Patient.count
    @total_filing = Filing.count
    @average_charts_per_patient = @total_patients > 0 ? (@total_charts.to_f / @total_patients).round(1) : 0
    @average_charts_per_day = @total_charts > 0 ? (@total_charts.to_f / (Chart.distinct.count(:t_date))).round(1) : 0
    @male_records = Patient.joins(:regi).where(regis: {gender: "Male"}).count
    @female_records = Patient.joins(:regi).where(regis: {gender: "Female"}).count
    @male_charts = Chart.joins(:regi).where(regis: {gender: "Male"}).count
    @female_charts = Chart.joins(:regi).where(regis: {gender: "Female"}).count
    @male_filing = Filing.joins(:regi).where(regis: {gender: "Male"}).count
    @female_filing = Filing.joins(:regi).where(regis: {gender: "Female"}).count
    @male_charts_per_patient = @total_male_patients > 0 ? (Chart.joins(:regi).where(regis: {gender: "Male"}).count.to_f / @total_male_patients).round(1) : 0
    @female_charts_per_patient = @total_female_patients > 0 ? (Chart.joins(:regi).where(regis: {gender: "Female"}).count.to_f / @total_female_patients).round(1) : 0
    @male_charts_per_day = @total_charts > 0 ? (Chart.joins(:regi).where(regis: {gender: "Male"}).count.to_f / (Chart.joins(:regi).where(regis: {gender: "Male"}).distinct.count(:t_date))).round(1) : 0
    @female_charts_per_day = @total_charts > 0 ? (Chart.joins(:regi).where(regis: {gender: "Female"}).count.to_f / (Chart.joins(:regi).where(regis: {gender: "Female"}).distinct.count(:t_date))).round(1) : 0
    @average_age = Regi.where("dob IS NOT NULL")
    .where("EXTRACT(YEAR FROM AGE(NOW(), dob)) BETWEEN 5 AND 100")
    .average("EXTRACT(YEAR FROM AGE(NOW(), dob))")
    .to_f.round(1)
    @average_male_age = Regi.where("dob IS NOT NULL")
    .where("EXTRACT(YEAR FROM AGE(NOW(), dob)) BETWEEN 5 AND 100")
    .where(gender: "Male")
    .average("EXTRACT(YEAR FROM AGE(NOW(), dob))")
    .to_f.round(1)
    @average_male_age = Regi.where("dob IS NOT NULL")
    .where("EXTRACT(YEAR FROM AGE(NOW(), dob)) BETWEEN 5 AND 100")
    .where(gender: "Male")
    .average("EXTRACT(YEAR FROM AGE(NOW(), dob))")
    .to_f.round(1)
    @average_female_age = Regi.where("dob IS NOT NULL")
    .where("EXTRACT(YEAR FROM AGE(NOW(), dob)) BETWEEN 5 AND 100")
    .where(gender: "Female")
    .average("EXTRACT(YEAR FROM AGE(NOW(), dob))")
    .to_f.round(1)

  end

  private
  
  # The helper method that does the actual security check
  def ensure_admin
    unless Current.user&.admin?
      redirect_to root_path, alert: "Access denied. Only Admins can view statistics."
    end
  end

end
 