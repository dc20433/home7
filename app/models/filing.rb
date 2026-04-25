class Filing < ApplicationRecord
  belongs_to :regi
  has_one_attached :image, dependent: :destroy
end
