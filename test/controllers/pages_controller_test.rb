require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "should get thank_you" do
    get pages_thank_you_url
    assert_response :success
  end
end
