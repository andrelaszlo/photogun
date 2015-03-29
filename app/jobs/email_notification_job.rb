require 'mailgun'
require 'sanitize'

class EmailNotificationJob < ActiveJob::Base
  queue_as :default

  rescue_from(Exception) do |exception|
    puts "Exception in %s" % self.class
    puts exception
    puts exception.backtrace
  end

  def perform(recipient, type, parameters)
    type = type.to_sym  # Active Job argument serialization doesn't support symbols

    if Rails.application.secrets.mailgun_api_key.nil?
      puts "MAILGUN_APIKEY not set"
      return
    end

    parameters[:url] = ENV['PUBLIC_URL']

    mailgun = Mailgun::Client.new ENV['MAILGUN_APIKEY']

    signature = "\n<br>/Photogun"

    templates = {
      :validation_failed => {
        :subject => "Photo processing failed",
        :template => "Sorry, but we couldn't do our thing with the photo %<title>p that you just sent! " \
                     "Either it wasn't a photo or our servers are having a bad day."},
      :validation_ok => {
        :subject => "Photo processed",
        :template => "The photo you sent has now been added to the gallery.<br>\n" \
                     "<a href='%<url>s/photos/%<id>s'>Photo: %<title>p at Photogun</a>"},
      :no_photos => {
        :subject => "No photos attached",
        :template => "Please add one or more photos as attachments.\n<br>" \
                     "Remember that the subject line will be used as title."},
      :not_whitelisted => {
        :subject => "You are not allowed to upload photos",
        :template => "We are overly paranoid, so only certain people can send photos.\n<br>"\
                     "Contact us if you think that you should be one of them."},
    }

    subject = templates[type][:subject]
    template = templates[type][:template]

    content = (template % parameters) << signature
    text = Sanitize.fragment content

    message = {:from    => 'noreply@pixel.0x81.com',
               :to      => recipient,
               :subject => subject,
               :html    => content,
               :text    => text }

    mailgun.send_message("pixel.0x81.com", message)
  end
end
