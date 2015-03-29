require 'test_helper'

require 'email_notification_job'

class PhotoTest < ActiveSupport::TestCase

  test "completed method" do
    photo = Photo.new

    photo.picture_processing = true
    photo.delayed_processing_ok = false
    assert_not photo.completed?

    photo.picture_processing = false
    photo.delayed_processing_ok = false
    assert_not photo.completed?

    photo.picture_processing = true
    photo.delayed_processing_ok = true
    assert_not photo.completed?

    photo.picture_processing = false
    photo.delayed_processing_ok = true
    assert photo.completed?
  end

  test "validate! verifies model" do
    s3_mock = mock()
    s3_mock.expects(:count_objects).returns(3)
    S3Helper.stubs(:new).returns(s3_mock)

    photo = Photo.new
    photo.expects(:save).returns(true)
    assert photo.validate!
    assert photo.delayed_processing_ok
  end

end
