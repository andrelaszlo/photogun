require 'mailgun'
require 'sanitize'

class EmailSuccessJob < ActiveJob::Base
  queue_as :email

  rescue_from(Exception) do |exception|
    puts "Exception in %s" % self.class
    puts exception
    puts exception.backtrace
  end

  def perform(recipient, photo_ids)

    apikey = Rails.application.secrets.mailgun_api_key

    if apikey.nil?
      puts "MAILGUN_APIKEY not set"
      return
    end

    mailgun = Mailgun::Client.new apikey

    # Apparently, hooking into the template/rendering mechanism outside of a
    # controller isn't so easy, so the html for the email will just be built
    # right here:

    template = "<p>Hi,</p>
<p>Your %<photo>s been uploaded!</p>
<p>Check %<them>s out %<links>s.</p>
<p>/Photogun</p>"

    base_url = ENV['PUBLIC_URL']

    links = photo_ids.map do |id|
      url = "#{base_url}/photos/#{id}"
      "<a href='#{url}'>here</a>"
    end

    plural = photo_ids.size > 1

    content = template % {
      :photo => plural ? "photos have" : "photo has",
      :them  => plural ? "them" : "it",
      :links => links.to_sentence
    }

    text = Sanitize.fragment content

    message = {:from    => 'noreply@pixel.0x81.com',
               :to      => recipient,
               :subject => 'Your photos were uploaded',
               :html    => content,
               :text    => text}

    mailgun.send_message("pixel.0x81.com", message)

    puts "Email sent"
  end
end
