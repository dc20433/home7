class Chart < ApplicationRecord
  belongs_to :regi
  validates :t_date, presence: true

  def self.ransackable_attributes(auth_object = nil)
    ["t_date", "subj", "obj", "assess", "plan"]
  end
  
  def self.ransackable_associations(auth_object = nil)
    ["regi"]
  end

end
