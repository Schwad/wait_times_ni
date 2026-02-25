# frozen_string_literal: true

require "test_helper"

class WaitTimeTest < ActiveSupport::TestCase
  def setup
    @hospital = hospitals(:royal_victoria)
    @wait_time = wait_times(:royal_victoria_1)
  end

  test "should be valid with hospital and value" do
    assert @wait_time.valid?
  end

  test "belongs to hospital" do
    assert_respond_to @wait_time, :hospital
    assert_instance_of Hospital, @wait_time.hospital
  end

  test "requires hospital" do
    @wait_time.hospital = nil
    assert_not @wait_time.valid?
  end

  test "requires value" do
    @wait_time.value = nil
    assert_not @wait_time.valid?
    assert_includes @wait_time.errors[:value], "can't be blank"
  end

  test "value can be zero" do
    @wait_time.value = 0
    assert @wait_time.valid?
  end
end
