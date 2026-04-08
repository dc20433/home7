class ApplicationController < ActionController::Base
  # Add this line to stop the "Pending Migration" screen from blocking you
   
  include Authentication
  # ... rest of your code
end
