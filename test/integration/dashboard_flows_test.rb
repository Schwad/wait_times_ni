# frozen_string_literal: true

require "test_helper"

class DashboardFlowsTest < ActionDispatch::IntegrationTest
  test "user can view live status dashboard" do
    get dashboard_path
    assert_response :success
    assert_select "h1", /Wait Times NI/
  end

  test "user can view trends page" do
    get trends_path
    assert_response :success
  end

  test "user can view compare page" do
    get compare_path
    assert_response :success
  end

  test "user can view heatmap page" do
    get heatmap_path
    assert_response :success
  end

  test "user can filter by time range" do
    get dashboard_path, params: { range: "7d" }
    assert_response :success

    get dashboard_path, params: { range: "30d" }
    assert_response :success

    get dashboard_path, params: { range: "90d" }
    assert_response :success

    get dashboard_path, params: { range: "1y" }
    assert_response :success
  end

  test "user can access API endpoint" do
    hospital = hospitals(:royal_victoria)
    
    get api_data_path, params: { hospital_id: hospital.id, granularity: "daily" }
    assert_response :success
    
    json = JSON.parse(response.body)
    assert_kind_of Array, json
  end

  test "API returns hourly data when requested" do
    hospital = hospitals(:royal_victoria)
    
    get api_data_path, params: { hospital_id: hospital.id, granularity: "hourly" }
    assert_response :success
  end

  test "handles missing hospital gracefully" do
    get api_data_path, params: { hospital_id: 999999, granularity: "daily" }
    assert_response :not_found
  end

  test "pages have proper accessibility structure" do
    get dashboard_path
    assert_response :success
    
    # Skip link
    assert_select "a.skip-link[href='#main-content']"
    
    # Main content landmark
    assert_select "main#main-content[role='main']"
    
    # Navigation landmark
    assert_select "nav[role='navigation']"
    
    # Footer landmark
    assert_select "footer[role='contentinfo']"
  end

  test "pages have proper lang attribute" do
    get dashboard_path
    assert_response :success
    assert_select "html[lang='en']"
  end
end
