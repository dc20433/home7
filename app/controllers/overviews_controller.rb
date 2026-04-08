class OverviewsController < ApplicationController
  # 1. This ensures a user is logged in before they can see ANY of these pages
  before_action :require_authentication
  
  # 2. This specifically locks the statistics page to Admins only
  before_action :ensure_admin, only: [:statistics]


  def patient_info
  @patients = Patient.includes(:regi).order("regis.p_name ASC, patients.v_date DESC")
  end
  
  def chart_name
  @charts = Chart.includes(:regi).order("regis.p_name ASC, charts.t_date DESC")
  end

  def chart_date
  @charts = Chart.includes(:regi).order(t_date: :desc, "regis.p_name": :asc)
  end

  def statistics
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
  end

  private
  
  # 3. This is the helper method that does the actual security check
  def ensure_admin
    unless Current.user&.admin?
      redirect_to root_path, alert: "Access denied. Only Admins can view statistics."
    end
  end

end
 