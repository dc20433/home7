class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  validates :email, presence: true, uniqueness: true

  # This matches the 3-tier requirement for user roles: user, manager, admin
  enum :role, { user: 0, manager: 1, admin: 2 }

  # Link a user to their specific patient profile
  belongs_to :patient, optional: true
end
