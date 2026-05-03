class Patient < ApplicationRecord
  belongs_to :regi

  # Add this line to allow the controller to bypass validations
  attr_accessor :skip_patient_validation
  attr_accessor :patient_consent

  # Update your validation to respect this flag
  validates :patient_consent, acceptance: { accept: "true" },
    unless: -> { skip_patient_validation || Current.user&.manager? || Current.user&.admin? }
  validates :v_date, uniqueness: { scope: :regi_id, message: "already has a record for this date" }
  before_save :sync_consent_with_signature

  def self.ransackable_attributes(auth_object = nil)
      # Attributes from the patients table itself
      [ "v_date", "weight", "com1", "com2", "com3", "d_onset", "referred", "di_list" ]
    end

  def self.ransackable_associations(auth_object = nil)
    [ "regi" ]
  end

  MARITAL_STATUS = [ "Single", "Married", "Divorced", "Widowed", "Separated" ].freeze

  HOSPITALIZED =
  [
    [ "No", "No" ],
    [ "Yes", "Yes" ]
  ]
  SEEN_DR =
  [
    [ "No", "No" ],
    [ "Yes", "Yes" ]
  ]
  ACU_BEFORE =
  [
    [ "No", "No" ],
    [ "Yes", "Yes" ]
  ]
  PREG =
  [
    [ "Select", "" ],
    [ "No", "No" ],
    [ "Yes", "Yes" ]
  ]
DI_LIST = [
    "Diabetes", "Hypertension", "Cancer", "Hepatitis", "Heart disease",
    "Crack/cocaine", "Enlarged lymph glands", "Hiv/aids", "Neck stiffness",
    "Seizure", "Palpitation", "Frequent colds", "Night sweating",
    "Chest pain or tightness", "Constipation", "Excess sweating",
    "Back/lower back pain", "Major depression", "Anxiety disorder",
    "Post traumatic stress disorder", "Bipolar disorder",
    "Borderline personality disorder"
  ].freeze

  F_LIST = [
    "Pregnant", "Irregular Cycle", "Painful Periods", "Menopause",
    "Heavy Flow", "PMS", "Endometriosis", "Ovarian Cysts"
  ].freeze

  # For Ransack to allow searching on these attributes and associations
  def self.ransackable_attributes(auth_object = nil)
    # Attributes from the patients table itself
    [ "v_date", "weight", "com1", "com2", "com3", "d_onset", "referred", "di_list" ]
  end

  def self.ransackable_associations(auth_object = nil)
    [ "regi" ]
  end

  private

  def signature_must_be_verified_by_patient
    unless patient_consent == "1" || patient_consent == true
      errors.add(:base, "You must check the consent box to verify your signature.")
    end
  end

  def patient_consent_and_signature_verification
    if signature.present? && !patient_consent
      errors.add(:patient_consent, "must be checked to verify your signature")
    end
  end

  def sync_consent_with_signature
    # If there is ink, set consent to true.
    # This keeps your Index/Regi lists accurate!
    self.patient_consent = true if signature.present?
  end

  def v_date_uniqueness_on_create
    if Patient.exists?(regi_id: regi_id, v_date: v_date)
      errors.add(:v_date, "already has a record. If this is a new visit, please select today's date.")
    end
  end
end
