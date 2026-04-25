class Patient < ApplicationRecord
  belongs_to :regi
  # validates :v_date, presence: true
  # validates :patient_consent, acceptance: true, on: :create

  MARITAL_STATUS =
  [
    [ "Select", "" ],
    [ "Single", "Single" ],
    [ "Married", "Married" ],
    [ "Divorced", "Divorced" ],
    [ "Widowed", "Widowed" ],
    [ "Other", "Other" ]
  ]
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
  HEALTH = %i[
    Diabetes;
    Hypertension;
    Cancer;
    Hepatitis;
    Heart_Disease;
    Crack/Cocaine;
    Enlarged_Lymph_Glands;
    HIV/AIDS;
    Neck_Stiffness;
    Seizure;
    Palpitation;
    Frequent_Colds;
    Night_Sweating;
    Chest_Pain_or_Tightness;
    Constipation;
    Excess_Sweating;
    Back/Lower_Back_Pain;
    Major_Depression;
    Anxiety_Disorder;
    Post_Traumatic_Stress_Disorder;
    Bypolar_Disorder;
    Borderline_Personality_Disorder
  ]

  # For Ransack to allow searching on these attributes and associations
  def self.ransackable_attributes(auth_object = nil)
    # Attributes from the patients table itself
    [ "v_date", "weight", "com1", "com2", "com3", "d_onset", "referred", "di_list" ]
  end

  def self.ransackable_associations(auth_object = nil)
    [ "regi" ]
  end
end
