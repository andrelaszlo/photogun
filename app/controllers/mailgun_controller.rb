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

    photos = []
    message.attachments.each do |attachment|
      begin
        photo = Photo.create(
          title: message.subject,
          sender: message.sender,
          picture: attachment
        )
        photos << photo.id
      rescue => e
        puts "Exception while saving photo"
        puts e
        puts e.backtrace
      end
    end

    if photos.empty?
         return render inline: "No photos saved"
    end

    render inline: "Ok %s" % photos.join(", ")
  end
end
