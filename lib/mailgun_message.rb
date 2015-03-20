class MailgunMessage
  def initialize(token, timestamp, signature, api_key: nil)
    @api_key = api_key || ENV['MAILGUN_APIKEY'] || ''
    if @api_key == ''
      ::Rails.logger.warn "No mailgun API key configured"
    end

    @token = token
    @timestamp = timestamp
    @signature = signature
  end

  def self.from_post(post, api_key: nil)
    self.new post['token'], post['timestamp'], post['signature'], api_key: api_key
  end

  def verified?
    verify @api_key, @token, @timestamp, @signature
  end

  # Verifies that a message is really sent by Mailgun
  private
  def verify(api_key, token, timestamp, signature)
    if ![api_key, token, timestamp, signature].all?
      return false
    end
    digest = OpenSSL::Digest::SHA256.new
    data = [timestamp, token].join
    signature == OpenSSL::HMAC.hexdigest(digest, api_key, data)
  end
end
