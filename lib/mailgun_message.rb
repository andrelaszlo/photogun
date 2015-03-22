class MailgunMessage

  attr_reader :sender, :subject, :attachments

  def initialize(token, timestamp, signature, sender, subject, attachments, api_key: nil)
    @api_key = api_key || ENV['MAILGUN_APIKEY']
    if @api_key.nil?
         ::Rails.logger.warn "No mailgun API key configured"
         @api_key = ''
    end

    # Signature data
    @token = token
    @timestamp = timestamp
    @signature = signature

    @sender = sender
    @subject = subject
    @attachments = attachments
  end

  # Constructs a MailgunMessage from the post data received through a Mailgun hook
  # If verification fails, +nil+ will be returned instead
  def self.from_post(post, api_key: nil)
    selected_data = [
      post['token'],
      post['timestamp'],
      post['signature'],
      post['sender'],
      post['Subject'],
      self.list_attachments(post)
    ]
    message = self.new *selected_data, api_key: api_key
    if message.verified? then message else nil end
  end

  def verified?
    verify @api_key, @token, @timestamp, @signature
  end

  def to_s
    representation = {
      :class => self.class,
      :subject => @subject,
      :sender => @sender
    }
    "#<%<class>s sender=%<sender>p subject=%<subject>p>" % representation
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

  # Returns a list of uploaded files from Mailgun's post data format
  private
  def self.list_attachments(post)
    if !post.key? "attachment-count"
      return []
    end

    count = post['attachment-count'].to_i

    attachments = (1..count).map do |index|
      key = "attachment-#{index}"
      post[key]
    end

    attachments.reject(&:nil?).freeze
  end
end
