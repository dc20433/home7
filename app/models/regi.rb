class Regi < ApplicationRecord
  has_many :filings
  has_many :filings, dependent: :destroy
  has_many :patients, dependent: :destroy
  has_many :charts, dependent: :destroy
  validates :last_name, :first_name, :gender, presence: true

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
    %w[first_name gender init last_name dob]
  end

  def p_age
    return unless dob.present?
    now = Time.now.utc.to_date
    now.year - dob.year - ((now.month > dob.month || (now.month == dob.month && now.day >= dob.day)) ? 0 : 1)
  end

  def p_name
    "#{last_name}, #{first_name} #{init}"
  end

end
