class PhotoVerifyJob < ActiveJob::Base
  queue_as :default

  MAX_RETRIES = (ENV['VERIFY_MAX_RETRIES'] || 5).to_i

  rescue_from(Exception) do |exception|
    puts "Exception in %s" % self.class
    puts exception
    puts exception.backtrace
  end

  def perform(photo_id, retries)
    begin
      puts "PhotoVerifyJob performing"
      photo = Photo.find(photo_id)

      # The validations seem to be half-broken for Delayed Paperclip so check
      # that the expected objects were saved in S3
      s3 = S3Helper.new

      expected_count = Photo.attachment_definitions[:picture][:styles].count
      count = s3.count_objects photo.picture.url

      if count < expected_count
        puts "Error: #{count} out of #{expected_count} styles were saved"
        if retries < MAX_RETRIES
          delay = (2**retries).seconds
          puts "Checking again in %s" % delay.inspect
          PhotoVerifyJob.set(wait: delay).perform_later(photo_id, retries+1)
        else
          puts "Max number of retries #{MAX_RETRIES} reached, giving up"
          EmailNotificationJob.perform_later photo.sender, 'validation_failed', {:title => photo.title}
          photo.delete
        end
        return
      end

      puts "#{count}/#{expected_count} styles saved"
      photo.delayed_processing_ok = true
      photo.save
      EmailNotificationJob.perform_later(photo.sender, 'validation_ok',
                                         {:title => photo.title,
                                          :id => photo_id})

    rescue => e
      puts e
      puts e.backtrace
    end

  end
end
