class ApplicationController < ActionController::Base
  include Authentication
  include Pagy::Backend
  #skip_before_action :require_authentication, raise: false
end