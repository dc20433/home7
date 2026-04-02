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
 end
 