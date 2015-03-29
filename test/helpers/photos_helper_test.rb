require 'test_helper'

class UserHelperTest < ActionView::TestCase
  include PhotosHelper

  test "redacting email" do
    assert_equal "f...@example.com", redact_email("foo@example.com")
    assert_equal "f...@example.com", redact_email("firstname.lastname@example.com")
    assert_equal "a...@example.com", redact_email("a@example.com")
  end
end
