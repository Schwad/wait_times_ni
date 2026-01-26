class DashboardController < ApplicationController
  before_action :set_date_range

  def index
    @hospitals = Hospital.all.order(:name)
    
    # Current status - live data
    @current_status = @hospitals.map do |h|
      {
        hospital: h,
        wait_time: h.current_wait_time,
        trend: h.trend_indicator
      }
    end

    # Peak and average from pre-aggregated stats
    @peak_stats = DailyStat.joins(:hospital)
                           .for_date_range(@start_date, @end_date)
                           .group("hospitals.name")
                           .select("hospitals.name, MAX(max_wait) as peak_wait")
                           .order("peak_wait DESC")

    @avg_stats = DailyStat.joins(:hospital)
                          .for_date_range(@start_date, @end_date)
                          .group("hospitals.name")
                          .select("hospitals.name, AVG(avg_wait) as avg_wait")
                          .order("avg_wait DESC")
  end

  def trends
    @hospitals = Hospital.all.order(:name)
    
    # Daily trend data - aggregated
    @daily_trends = @hospitals.map do |hospital|
      stats = hospital.daily_stats
                      .for_date_range(@start_date, @end_date)
                      .order(:date)
                      .pluck(:date, :avg_wait)
      
      { name: hospital.name, data: stats.to_h }
    end
  end

  def heatmap
    @hospitals = Hospital.all.order(:name)
    @selected_hospital = Hospital.find(params[:hospital_id]) if params[:hospital_id].present?
    @selected_hospital ||= @hospitals.first

    # Build heatmap data: day of week x hour
    @heatmap_data = build_heatmap_data(@selected_hospital)
  end

  def compare
    @hospitals = Hospital.all.order(:name)
    @selected_ids = params[:hospital_ids]&.map(&:to_i) || @hospitals.first(3).map(&:id)
    @selected_hospitals = Hospital.where(id: @selected_ids)

    @comparison_data = @selected_hospitals.map do |hospital|
      stats = hospital.daily_stats
                      .for_date_range(@start_date, @end_date)
                      .order(:date)
                      .pluck(:date, :avg_wait)
      
      { name: hospital.name, data: stats.to_h }
    end
  end

  def live
    @hospitals = Hospital.all.order(:name)
    @selected_hospital = Hospital.find(params[:hospital_id]) if params[:hospital_id].present?
    @selected_hospital ||= @hospitals.first

    # Only load recent hourly stats for performance
    @hourly_data = @selected_hospital.hourly_stats
                                      .for_date_range(@start_date, @end_date)
                                      .order(:hour)
                                      .pluck(:hour, :avg_wait)
  end

  def api_data
    hospital = Hospital.find(params[:hospital_id])
    
    data = case params[:granularity]
    when "hourly"
      hospital.hourly_stats
              .for_date_range(@start_date, @end_date)
              .order(:hour)
              .pluck(:hour, :avg_wait, :min_wait, :max_wait)
              .map { |h, avg, min, max| { time: h, avg: avg, min: min, max: max } }
    else # daily
      hospital.daily_stats
              .for_date_range(@start_date, @end_date)
              .order(:date)
              .pluck(:date, :avg_wait, :min_wait, :max_wait)
              .map { |d, avg, min, max| { date: d, avg: avg, min: min, max: max } }
    end

    render json: data
  end

  private

  def set_date_range
    @range = params[:range] || "30d"
    
    @end_date = Date.current
    @start_date = case @range
    when "7d" then 7.days.ago.to_date
    when "30d" then 30.days.ago.to_date
    when "90d" then 90.days.ago.to_date
    when "1y" then 1.year.ago.to_date
    when "all" then 10.years.ago.to_date
    else
      if params[:start_date].present? && params[:end_date].present?
        @end_date = Date.parse(params[:end_date])
        Date.parse(params[:start_date])
      else
        30.days.ago.to_date
      end
    end
  end

  def build_heatmap_data(hospital)
    # Get average wait times by day of week and hour
    data = hospital.wait_times
                   .group("EXTRACT(DOW FROM created_at)::INT", "EXTRACT(HOUR FROM created_at)::INT")
                   .average(:value)
    
    # Convert to heatmap format
    result = []
    (0..6).each do |day|
      (0..23).each do |hour|
        value = data[[day, hour]] || 0
        result << { x: hour, y: Date::DAYNAMES[day], v: value.round }
      end
    end
    result
  end
end
