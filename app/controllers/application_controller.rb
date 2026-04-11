class ApplicationController < ActionController::Base
  include Authentication
  #skip_before_action :require_authentication, raise: false
end