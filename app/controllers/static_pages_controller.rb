class StaticPagesController < ApplicationController
  def index
    @hospitals = Hospital.all
    @hospitals_peak_wait_time = Hospital.joins(:wait_times)
                                       .group('hospitals.name')
                                       .select('hospitals.name, MAX(wait_times.value) AS peak_wait')
    @hospitals_average_wait_time = Hospital.joins(:wait_times)
                                       .group('hospitals.name')
                                       .select('hospitals.name, AVG(wait_times.value) AS avg_wait')
    @data_by_hospitals = @hospitals.map do |hospital|
      data = (0..6).map do |wday|
        wait_times_on_day = hospital.wait_times
                                    .where('EXTRACT(DOW FROM created_at)::INT = ?', wday)
                                    .average(:value)
        [Date::DAYNAMES[wday], wait_times_on_day || 0]
      end.to_h

      { name: hospital.name, data: data }
    end

    @data_by_hospitals_hour = @hospitals.map do |hospital|
      data = (0..23).map do |hour|
        wait_times_on_hour = hospital.wait_times
                                    .where('EXTRACT(HOUR FROM created_at)::INT = ?', hour)
                                    .average(:value)
        [hour, wait_times_on_hour || 0]
      end.to_h

      { name: hospital.name, data: data }
    end

    @hospitals_trend_wait_times = Hospital.joins(:wait_times)
                                          .group('hospitals.name, DATE_TRUNC(\'day\', wait_times.created_at)')
                                          .select('hospitals.name, DATE_TRUNC(\'day\', wait_times.created_at) AS day, AVG(wait_times.value) as avg_wait')
  end

end
