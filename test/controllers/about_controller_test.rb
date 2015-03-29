require 'test_helper'

class AboutControllerTest < ActionController::TestCase

  test "about email" do
    get :index
    assert_response :success

    assert_select '*', /upload@mailgun\.example\.com/
  end

end
