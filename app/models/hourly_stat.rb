class HourlyStat < ApplicationRecord
  belongs_to :hospital

  scope :for_date_range, ->(start_date, end_date) { where(hour: start_date.beginning_of_day..end_date.end_of_day) }
  scope :recent, ->(days = 7) { where("hour >= ?", days.days.ago.beginning_of_day) }

  def self.aggregate_for_hospital(hospital, hour_start)
    hour_end = hour_start + 1.hour
    wait_times = hospital.wait_times.where(created_at: hour_start...hour_end)

    return if wait_times.empty?

    find_or_initialize_by(hospital: hospital, hour: hour_start).tap do |stat|
      stat.min_wait = wait_times.minimum(:value)
      stat.max_wait = wait_times.maximum(:value)
      stat.avg_wait = wait_times.average(:value)
      stat.sample_count = wait_times.count
      stat.save!
    end
  end
end
