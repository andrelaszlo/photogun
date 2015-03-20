require 'test_helper'

class MailgunMessageTest < ActionController::TestCase

  # Data expected to be correct, with a spoofed API key of course
  @@data = {
    :api_key => "key-3760e2f8c5971a69fb1fce0bfcc209e1",
    "token" => 'a6707ea10b181809ad4a6c56892b19bc62f30bed71c13af15a',
    "timestamp" => 1426855282,
    "signature" => "0ce415300f445850fb7152ca711f32ee9b11c16a908de84ae648141b9528d9e7"
  }

  test "basic mailgun signatures" do
    message = MailgunMessage.from_post @@data, api_key: @@data[:api_key]
    assert message.verified?, "Signature is ok"
  end

  test "environment configuration" do
    ENV['MAILGUN_APIKEY'] = @@data[:api_key]
    message = MailgunMessage.from_post @@data
    assert message.verified?, "Reading API key from environment works"
  end

  test "broken mailgun signatures" do
    [:api_key, "token", "timestamp", "signature"].each do |k|
      bad_data = @@data.clone
      bad_data[k] = ''
      message = MailgunMessage.from_post bad_data, api_key: bad_data[:api_key]
      assert_not message.verified?, "Message signature is bad because %p changed" % k
    end
  end

end
