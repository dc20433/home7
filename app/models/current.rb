class Current < ActiveSupport::CurrentAttributes
  attribute :session
  delegate :user, to: :session, allow_nil: true

  def admin?
    user&.admin?
  end

  def manager?
    user&.manager?
  end
end
