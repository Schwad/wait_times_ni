# frozen_string_literal: true

require "test_helper"

class DailyStatTest < ActiveSupport::TestCase
  def setup
    @hospital = hospitals(:royal_victoria)
    @daily_stat = daily_stats(:royal_victoria_today)
  end

  test "should be valid with required attributes" do
    assert @daily_stat.valid?
  end

  test "belongs to hospital" do
    assert_respond_to @daily_stat, :hospital
    assert_instance_of Hospital, @daily_stat.hospital
  end

  test "requires hospital" do
    @daily_stat.hospital = nil
    assert_not @daily_stat.valid?
  end

  test "requires date" do
    @daily_stat.date = nil
    assert_not @daily_stat.valid?
  end

  test "unique hospital-date combination" do
    duplicate = DailyStat.new(
      hospital: @hospital,
      date: @daily_stat.date,
      avg_wait: 50
    )
    assert_not duplicate.valid?
  end

  test "for_date_range scope filters correctly" do
    start_date = 7.days.ago.to_date
    end_date = Date.current
    
    stats = DailyStat.for_date_range(start_date, end_date)
    
    stats.each do |stat|
      assert stat.date >= start_date
      assert stat.date <= end_date
    end
  end
end
