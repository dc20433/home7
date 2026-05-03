class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

  # This tells Rails to look for a record in the 'regis' table
  # that has a 'user_id' matching this user's ID.
  has_one :regi, dependent: :nullify

  validates :email, presence: true, uniqueness: true

  enum :role, { standard: 0, manager: 1, admin: 2, patient: 3 }

  def needs_password_change?
    # If you don't have an 'activated' boolean, you can check if
    # a 'password_changed_at' timestamp is nil, or if they are
    # still using the temporary role state.
    !self.activated?
  end
end
