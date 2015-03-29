require 'test_helper'

class UserFlowsTest < ActionDispatch::IntegrationTest
  test "browse empty gallery" do
    Photo.delete_all
    get "/"
    assert_response :success
    assert_select 'div.empty'
  end

  test "nonexisting photo" do
    assert_raises ActiveRecord::RecordNotFound do
      get "/photos/999"
    end
  end

  # TODO: upload, although it's mostly covered in the mailgun controller test
end
