class DailyStat < ApplicationRecord
  belongs_to :hospital

  validates :hospital, :date, presence: true
  validates :hospital_id, uniqueness: { scope: :date, message: "already has stats for this date" }

  scope :for_date_range, ->(start_date, end_date) { where(date: start_date..end_date) }
  scope :recent, ->(days = 30) { where("date >= ?", days.days.ago.to_date) }

  def self.aggregate_for_hospital(hospital, date)
    wait_times = hospital.wait_times.where(
      "DATE(created_at) = ?", date
    )

    return if wait_times.empty?

    find_or_initialize_by(hospital: hospital, date: date).tap do |stat|
      stat.min_wait = wait_times.minimum(:value)
      stat.max_wait = wait_times.maximum(:value)
      stat.avg_wait = wait_times.average(:value)
      stat.sample_count = wait_times.count
      stat.save!
    end
  end
end
