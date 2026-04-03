class Regi < ApplicationRecord
  has_many :filings
  has_many :filings, dependent: :destroy
  has_many :patients, dependent: :destroy
  has_many :charts, dependent: :destroy
  validates :last_name, :first_name, :gender, presence: true
  before_validation :set_p_name

  GENDER_OPTIONS = [
    ['Select', ''],
    ['Male', 'Male'],
    ['Female', 'Female'],
    ['Other', 'Other']
  ]
  def self.ransackable_associations(auth_object = nil)
    ["charts", "filings", "patients"]
  end

  def self.ransackable_attributes(auth_object = nil)
    ["last_name", "first_name", "dob", "gender", "created_at"]
  end

  def p_age
    return unless dob.present?
    now = Time.now.utc.to_date
    now.year - dob.year - ((now.month > dob.month || (now.month == dob.month && now.day >= dob.day)) ? 0 : 1)
  end

  def set_p_name
    self.p_name = "#{last_name}, #{first_name} #{init}".strip
  end
  
  # Move the logic into a public method (remove 'def set_p_gender')
  def p_gender
    gender.present? ? gender : "<No gender data>"
  end
end
