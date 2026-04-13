class ApplicationController < ActionController::Base
  include Authentication
  include Pagy::Backend
  #skip_before_action :require_authentication, raise: false
  before_action :Current.session.updated_at = Time.current if Current.session
end