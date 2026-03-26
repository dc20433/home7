class OverviewsController < ApplicationController
   def patient_info
   end
   
   def chart_name
     @chart_name = Chart.order("name, t_date DESC")
   end
 
   def chart_date
     @chart_date = Chart.order("t_date DESC, name")
   end
 end
 