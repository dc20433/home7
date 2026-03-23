class Chart < ApplicationRecord
  belongs_to :regi
  validates :t_date, presence: true
end
