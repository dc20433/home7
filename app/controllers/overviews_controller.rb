class OverviewsController < ApplicationController
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
    @average_charts_per_patient = @total_patients > 0 ? (@total_charts.to_f / @total_patients).round(2) : 0
   end
 end
 