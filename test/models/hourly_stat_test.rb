# frozen_string_literal: true

require "test_helper"

class HourlyStatTest < ActiveSupport::TestCase
  def setup
    @hospital = hospitals(:royal_victoria)
    @hourly_stat = hourly_stats(:royal_victoria_morning)
  end

  test "should be valid with required attributes" do
    assert @hourly_stat.valid?
  end

  test "belongs to hospital" do
    assert_respond_to @hourly_stat, :hospital
    assert_instance_of Hospital, @hourly_stat.hospital
  end

  test "requires hospital" do
    @hourly_stat.hospital = nil
    assert_not @hourly_stat.valid?
  end

  test "requires hour" do
    @hourly_stat.hour = nil
    assert_not @hourly_stat.valid?
  end

  test "for_date_range scope filters correctly" do
    start_date = 7.days.ago.to_date
    end_date = Date.current
    
    stats = HourlyStat.for_date_range(start_date, end_date)
    
    stats.each do |stat|
      assert stat.hour.to_date >= start_date
      assert stat.hour.to_date <= end_date
    end
  end
end
