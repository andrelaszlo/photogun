require 'pp'
require 'openssl'

class MailgunController < ApplicationController
  # Mailgun will not use the CSRF tokens provided by rails
  skip_before_filter :verify_authenticity_token

  # Handles emails forwarded by Mailgun
  def webhook
    message = MailgunMessage.from_post params

    if message.nil? || ! message.verified?
      return failure "Bad signature"
    end

    if !EmailWhitelist.whitelisted? message.sender
      EmailNotificationJob.perform_later message.sender, 'not_whitelisted', {}
      return failure "Sender not allowed"
    end

    puts "Got message #{message}"

    photos = []
    message.attachments.each do |attachment|
      photo = Photo.create(
        title: message.subject,
        sender: message.sender,
        picture: attachment
      )
      if photo.persisted?
        photos << photo.id
        PhotoVerifyJob.perform_later(photo.id, 0) unless photo.id.nil?
      end
    end

    if photos.reject(&:nil?).empty?
      EmailNotificationJob.perform_later message.sender, 'no_photos', {}
      return success "No photos saved"
    end

    EmailSuccessJob.perform_later message.sender, photos
    success "Ok %s" % photos.join(", ")
  end

  private
  def success(message)
    render inline: message
  end

  def failure(message)
    render inline: message, :status => :not_acceptable
  end
end
