# app/models/hospital.rb
class Hospital < ApplicationRecord
  has_many :wait_times, dependent: :destroy

  validates :name, presence: true, uniqueness: true
end
