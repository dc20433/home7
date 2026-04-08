class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  validates :email, presence: true, uniqueness: true

  # This matches your 3-tier request
  enum :role, { user: 0, manager: 1, admin: 2 }

  # Optional: Link a user to their specific patient profile
  belongs_to :patient, optional: true 
end