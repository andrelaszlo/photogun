require 'pp'
require 'openssl'

class MailgunController < ApplicationController
  # Mailgun will not use the CSRF tokens provided by rails
  skip_before_filter :verify_authenticity_token

  # Handles emails forwarded by Mailgun
  def webhook
    message = MailgunMessage.from_post params

    if message.verified?
      puts "Got message #{message}"

      p = Photo.new(
        title: message.subject,
        sender: message.sender
      )
      p.save

      return render inline: "ok!"
    end

    render inline: "Bad signature", :status => :not_acceptable
  end
end
