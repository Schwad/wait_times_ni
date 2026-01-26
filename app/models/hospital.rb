# app/models/hospital.rb
class Hospital < ApplicationRecord
  has_many :wait_times, dependent: :destroy
  has_many :daily_stats, dependent: :destroy
  has_many :hourly_stats, dependent: :destroy

  validates :name, presence: true, uniqueness: true

  def current_wait_time
    wait_times.order(created_at: :desc).first&.value
  end

  def trend_indicator
    recent = wait_times.order(created_at: :desc).limit(4).pluck(:value)
    return :stable if recent.size < 2
    
    avg_recent = recent.first(2).sum.to_f / 2
    avg_older = recent.last(2).sum.to_f / 2
    
    diff = avg_recent - avg_older
    if diff > 5
      :rising
    elsif diff < -5
      :falling
    else
      :stable
    end
  end
end
