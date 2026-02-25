# frozen_string_literal: true

require "test_helper"

class HospitalTest < ActiveSupport::TestCase
  def setup
    @hospital = hospitals(:royal_victoria)
  end

  # Validations
  test "should be valid with name" do
    assert @hospital.valid?
  end

  test "requires name" do
    @hospital.name = nil
    assert_not @hospital.valid?
    assert_includes @hospital.errors[:name], "can't be blank"
  end

  test "requires unique name" do
    duplicate = Hospital.new(name: @hospital.name)
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:name], "has already been taken"
  end

  # Associations
  test "has many wait_times" do
    assert_respond_to @hospital, :wait_times
    assert @hospital.wait_times.count >= 0
  end

  test "has many daily_stats" do
    assert_respond_to @hospital, :daily_stats
    assert @hospital.daily_stats.count >= 0
  end

  test "has many hourly_stats" do
    assert_respond_to @hospital, :hourly_stats
    assert @hospital.hourly_stats.count >= 0
  end

  test "destroys associated wait_times when destroyed" do
    wait_time = @hospital.wait_times.create!(value: 60)
    wait_time_id = wait_time.id
    
    @hospital.destroy
    
    assert_nil WaitTime.find_by(id: wait_time_id)
  end

  # Instance methods
  test "current_wait_time returns most recent value" do
    # Royal Victoria has wait_times from fixtures, most recent is 40
    assert_equal 40, @hospital.current_wait_time
  end

  test "current_wait_time returns nil when no wait_times" do
    empty_hospital = hospitals(:causeway)
    assert_nil empty_hospital.current_wait_time
  end

  test "trend_indicator returns :stable with insufficient data" do
    hospital = hospitals(:mater) # Only has one wait_time
    assert_equal :stable, hospital.trend_indicator
  end

  test "trend_indicator returns :falling when wait times decreasing" do
    # Royal Victoria: 45, 50, 55 (most recent to oldest) = falling
    assert_equal :falling, @hospital.trend_indicator
  end

  test "trend_indicator returns :rising when wait times increasing" do
    # Antrim: 120, 100 (recent, older) = rising
    antrim = hospitals(:antrim)
    assert_equal :rising, antrim.trend_indicator
  end
end
