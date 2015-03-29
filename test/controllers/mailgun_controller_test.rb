require 'test_helper'

class MailgunControllerTest < ActionController::TestCase

  @@data = {
    "token"     => 'a6707ea10b181809ad4a6c56892b19bc62f30bed71c13af15a',
    "timestamp" => 1426855282,
    "signature" => "0ce415300f445850fb7152ca711f32ee9b11c16a908de84ae648141b9528d9e7",
    "sender"    => 'foo@example.com',
    "Subject"   => 'title',
  }

  test "reject empty post" do
    post :webhook
    assert_response :not_acceptable
  end

  test "accept signature" do
    s3_mock = mock()
    s3_mock.expects(:count_objects).returns(3)
    S3Helper.stubs(:new).returns(s3_mock)

    expect_sent_emails 2, [/your photos were uploaded/i, /photo processed/i]

    Rails.application.secrets.email_whitelist = "foo@example.com"

    data = @@data.clone.update({
      "attachment-count" => "1",
      "attachment-1" => fixture_file_upload('files/small_photo.jpg', 'image/jpeg')
    })

    post :webhook, data
    assert_response :success
    assert_select '*', /ok \d+/i
  end

  test "not whitelisted" do
    expect_sent_emails 1, [/you are not allowed to upload photos/i]
    data = @@data.clone.update(sender: "not.whitelisted@example.com")
    post :webhook, data
    assert_response :not_acceptable
  end

  test "no attachments" do
    Rails.application.secrets.email_whitelist = "foo@example.com"
    expect_sent_emails 1, [/no photos attached/i]
    assert_response :success
    post :webhook, @@data
  end

  test "broken attachment" do
    Rails.application.secrets.email_whitelist = "foo@example.com"
    expect_sent_emails 1, [/no photos attached/i]

    data = @@data.clone.update({
      "attachment-count" => "1",
      "attachment-1" => fixture_file_upload('files/random_data.dat', 'application/octet-stream')
    })

    post :webhook, data
    assert_select '*', /no photos saved/i
  end

  private
  def expect_sent_emails(sent, subject_matchers)
    Rails.application.secrets.mailgun_api_key = "key-3760e2f8c5971a69fb1fce0bfcc209e1"

    subject_matcher = Regexp.union subject_matchers
    mock_mailgun = mock()
    mock_mailgun
      .expects(:send_message)
      .times(sent)
      .with() { |_, message|
        !subject_matcher.match(message[:subject]).nil?
      }
    Mailgun::Client.stubs(:new).returns(mock_mailgun)
  end
end
