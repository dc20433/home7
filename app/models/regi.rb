class Regi < ApplicationRecord
  has_many :filings
  has_many :filings, dependent: :destroy
  has_many :patients, dependent: :destroy
  has_many :charts, dependent: :destroy
  validates :last_name, :first_name, :gender, presence: true
  before_validation :set_p_name

  GENDER_OPTIONS = [
    [ "Select", "" ],
    [ "Male", "Male" ],
    [ "Female", "Female" ],
    [ "Other", "Other" ]
  ]
  def self.ransackable_associations(auth_object = nil)
    [ "charts", "filings", "patients" ]
  end

  def self.ransackable_attributes(auth_object = nil)
    [ "last_name", "first_name", "p_name", "dob", "gender" ]
  end

  def p_age
    return unless dob.present?
    now = Time.now.utc.to_date
    now.year - dob.year - ((now.month > dob.month || (now.month == dob.month && now.day >= dob.day)) ? 0 : 1)
  end

  # Add this getter method to regi.rb
  def p_name
    # read_attribute(:p_name) gets the value from the DB column
    db_value = read_attribute(:p_name)

    if db_value.present?
      db_value
    else
      # Fallback logic if the column is empty (common for home2 imports)
      "#{last_name}, #{first_name} #{init}".strip
    end
  end

  def set_p_name
    return if last_name.blank? && first_name.blank?
    self.p_name = "#{last_name}, #{first_name} #{init}".strip.gsub(/\s+/, " ")
  end

  # Move the logic into a public method (remove 'def set_p_gender')
  def p_gender
    gender.present? ? gender : "<No gender data>"
  end
end
