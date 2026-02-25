# frozen_string_literal: true

require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
  def setup
    @hospital = hospitals(:royal_victoria)
  end

  test "should get index" do
    get dashboard_path
    assert_response :success
  end

  test "index shows current status for all hospitals" do
    get dashboard_path
    assert_response :success
    assert_select ".hospital-card", minimum: 1
  end

  test "should get trends" do
    get trends_path
    assert_response :success
  end

  test "should get heatmap" do
    get heatmap_path
    assert_response :success
  end

  test "heatmap accepts hospital_id parameter" do
    get heatmap_path, params: { hospital_id: @hospital.id }
    assert_response :success
  end

  test "should get compare" do
    get compare_path
    assert_response :success
  end

  test "compare accepts multiple hospital_ids" do
    hospital2 = hospitals(:antrim)
    get compare_path, params: { hospital_ids: [@hospital.id, hospital2.id] }
    assert_response :success
  end

  test "api_data returns JSON" do
    get api_data_path, params: { hospital_id: @hospital.id }, as: :json
    assert_response :success
    
    json = JSON.parse(response.body)
    assert_kind_of Array, json
  end

  test "api_data supports daily granularity" do
    get api_data_path, params: { hospital_id: @hospital.id, granularity: "daily" }
    assert_response :success
  end

  test "api_data supports hourly granularity" do
    get api_data_path, params: { hospital_id: @hospital.id, granularity: "hourly" }
    assert_response :success
  end

  test "api_data returns 404 for missing hospital" do
    get api_data_path, params: { hospital_id: 999999 }
    assert_response :not_found
  end

  test "index supports different time ranges" do
    %w[7d 30d 90d 1y all].each do |range|
      get dashboard_path, params: { range: range }
      assert_response :success, "Failed for range: #{range}"
    end
  end

  test "index supports custom date range" do
    get dashboard_path, params: { 
      start_date: 7.days.ago.to_date.to_s,
      end_date: Date.current.to_s
    }
    assert_response :success
  end
end
