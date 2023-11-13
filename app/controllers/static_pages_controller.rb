class StaticPagesController < ApplicationController
  def index
    @hospitals = Hospital.all
    @hospitals_peak_wait_time = Hospital.joins(:wait_times)
                                       .group('hospitals.name')
                                       .select('hospitals.name, MAX(wait_times.value) AS peak_wait')
    @hospitals_average_wait_time = Hospital.joins(:wait_times)
                                       .group('hospitals.name')
                                       .select('hospitals.name, AVG(wait_times.value) AS avg_wait')
    @days_of_week = ("Sunday".."Saturday").to_a
    @data_by_day = @days_of_week.map do |day|
      {
        name: day,
        data: Hospital.joins(:wait_times)
                      .where('EXTRACT(DOW FROM wait_times.created_at)::INT = ?', @days_of_week.index(day))
                      .group('hospitals.name')
                      .average('wait_times.value')
      }
    end

    @hospitals_trend_wait_times = Hospital.joins(:wait_times)
                                          .group('hospitals.name, DATE_TRUNC(\'month\', wait_times.created_at)')
                                          .select('hospitals.name, DATE_TRUNC(\'month\', wait_times.created_at) AS month, AVG(wait_times.value) as avg_wait')
  end

end
