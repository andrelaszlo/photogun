require 'test_helper'

class PhotosControllerTest < ActionController::TestCase

  test "show list of processed pictures" do
    get :index
    assert_response :success

    assert_select 'li' do |elements|
      assert_equal 2, elements.count, "only completed pictures shows"
    end
  end

  test "show existing photo" do
    get :show, id: photos(:completed).id
    assert_response :success
    assert_select 'h2', Regexp.new(photos(:completed).title)
  end

  test "show unfinished photo" do
    get :show, id: photos(:processing).id
    assert_response :success
    assert_select 'div.photo', /still processing/
  end

end
