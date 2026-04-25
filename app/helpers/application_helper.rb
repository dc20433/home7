module ApplicationHelper
  include Pagy::Frontend

  def session_duration(user)
   return "N/A" unless user.last_sign_in_at && user.last_sign_out_at

   seconds = (user.last_sign_out_at - user.last_sign_in_at).to_i
   return "0s" if seconds <= 0

   hours = seconds / 3600
   minutes = (seconds % 3600) / 60

   if hours > 0
      "#{hours}h #{minutes}m"
   else
      "#{minutes}m #{seconds % 60}s"
   end
   end
end
