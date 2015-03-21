require 'pp'
require 'openssl'

class MailgunController < ApplicationController
  # Mailgun will not use the CSRF tokens provided by rails
  skip_before_filter :verify_authenticity_token

  # Handles emails forwarded by Mailgun
  def webhook
    message = MailgunMessage.from_post params

    if message.nil? || ! message.verified?
         return render inline: "Bad signature", :status => :not_acceptable
    end

    puts "Got message #{message}"

    message.attachments.each do |attachment|
      # TODO: wrap this in a begin/rescue
      Photo.create(
        title: message.subject,
        sender: message.sender,
        picture: attachment
      )
    end

    return render inline: "Ok"
  end
end
