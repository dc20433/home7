require "test_helper"

class RegisControllerTest < ActionDispatch::IntegrationTest
  setup do
    @regi = regis(:one)
  end

  test "should get index" do
    get regis_url
    assert_response :success
  end

  test "should get new" do
    get new_regi_url
    assert_response :success
  end

  test "should create regi" do
    assert_difference("Regi.count") do
      post regis_url, params: { regi: { dob: @regi.dob, first_name: @regi.first_name, gender: @regi.gender, init: @regi.init, last_name: @regi.last_name } }
    end

    assert_redirected_to regi_url(Regi.last)
  end

  test "should show regi" do
    get regi_url(@regi)
    assert_response :success
  end

  test "should get edit" do
    get edit_regi_url(@regi)
    assert_response :success
  end

  test "should update regi" do
    patch regi_url(@regi), params: { regi: { dob: @regi.dob, first_name: @regi.first_name, gender: @regi.gender, init: @regi.init, last_name: @regi.last_name } }
    assert_redirected_to regi_url(@regi)
  end

  test "should destroy regi" do
    assert_difference("Regi.count", -1) do
      delete regi_url(@regi)
    end

    assert_redirected_to regis_url
  end
end
