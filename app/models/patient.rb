class Patient < ApplicationRecord
  belongs_to :regi
  validates :v_date, presence: true

  MARITAL_STATUS = 
  [
    ['Select', ''],
    ['Single', 'Single'],
    ['Married', 'Married'],
    ['Divorced', 'Divorced'],
    ['Widowed', 'Widowed'],
    ['Other', 'Other']
  ]
  HOSPITALIZED = 
  [
    ['No', 'No'],
    ['Yes', 'Yes']
  ]
  SEEN_DR = 
  [
    ['No', 'No'],
    ['Yes', 'Yes']
  ]
  ACU_BEFORE =
  [
    ['No', 'No'],
    ['Yes', 'Yes']
  ]
  PREG =
  [
    ['NA', 'NA'],
    ['No', 'No'],
    ['Yes', 'Yes']
  ]
  # List every checkbox column name and its display label
  HEALTH_ISSUES = {
    diabetes: "Diabetes;",
    hypertension: "Hypertension;",
    cancer: "Cancer;",
    hepatitis: "Hepatitis;",
    heart_disease: "Heart disease;",
    crack_cocaine: "Crack/cocaine;",
    lymph: "Enlarged lymph glands;",
    hiv_aids: "Hiv/aids;",
    neck_stiffness: "Neck stiffness;",
    seizure: "Seizure;",
    palpitation: "Palpitation;",
    frequent_colds: "Frequent colds;",
    night_sweating: "Night sweating;",
    chest_pain: "Chest pain or tightness;",
    constipation: "Constipation;",
    excess_sweating: "Excess sweating;",
    back_pain: "Back/lower back pain;",
    depression: "Major depression;",
    anxiety: "Anxiety disorder;",
    ptsd: "Post traumatic stress disorder;",
    bypolar: "Bypolar disorder;",
    borderline: "Borderline personality disorder"
  }

  # app/models/patient.rb
  def active_health_issues
  # 1. Start an empty list
  issues = []
  # 2. Loop through the HEALTH_ISSUES hash
  HEALTH_ISSUES.each do |column, label|
    # If the database column is 'true', add the clean label (minus the semicolon)
    issues << label.gsub(/;/, '') if self.send(column)
  end
  # 3. Add "Other Issues" if they exist
  issues << self.o_dis if self.o_dis.present?
  # 4. Add "Pregnant" status if applicable
  issues << "Pregnant" if self.preg == "Yes"
  # 5. Join them all with '/' connector
  issues.to_sentence(words_connector: ' / ', last_word_connector: ' / ', two_words_connector: ' / ')
  end

  def self.ransackable_attributes(auth_object = nil)
    # Attributes from the patients table itself
    ["v_date", "weight", "com1", "com2", "com3", "d_onset", "referred", "di_list"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["regi"]
  end

end
