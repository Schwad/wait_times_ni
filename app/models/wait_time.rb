# app/models/wait_time.rb
class WaitTime < ApplicationRecord
  belongs_to :hospital

  validates :value, presence: true, numericality: { only_integer: true }
end
