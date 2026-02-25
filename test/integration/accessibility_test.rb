# frozen_string_literal: true

require "test_helper"

class AccessibilityTest < ActionDispatch::IntegrationTest
  test "dashboard has skip link for keyboard navigation" do
    get dashboard_path
    assert_response :success
    assert_select "a.skip-link[href='#main-content']"
  end

  test "main content has proper landmark" do
    get dashboard_path
    assert_response :success
    assert_select "main#main-content[role='main']"
  end

  test "navigation has proper landmark" do
    get dashboard_path
    assert_response :success
    assert_select "nav[role='navigation']"
  end

  test "footer has proper landmark" do
    get dashboard_path
    assert_response :success
    assert_select "footer[role='contentinfo']"
  end

  test "header has proper landmark" do
    get dashboard_path
    assert_response :success
    assert_select "header[role='banner']"
  end

  test "pages have proper lang attribute" do
    get dashboard_path
    assert_response :success
    assert_select "html[lang='en']"
  end

  test "navigation links have aria-current for active page" do
    get dashboard_path
    assert_response :success
    assert_select "nav a[aria-current='page']"
  end

  test "trends page has proper structure" do
    get trends_path
    assert_response :success
    assert_select "main#main-content"
  end

  test "compare page has proper structure" do
    get compare_path
    assert_response :success
    assert_select "main#main-content"
  end

  test "heatmap page has proper structure" do
    get heatmap_path
    assert_response :success
    assert_select "main#main-content"
  end
end
