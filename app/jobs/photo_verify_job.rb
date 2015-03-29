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

      validated = photo.validate!

      if ! validated
        if retries < MAX_RETRIES
          delay = (2**retries).seconds
          puts "Checking again in %s" % delay.inspect
          begin
            PhotoVerifyJob.set(wait: delay)
          rescue NotImplementedError => e
          end
          PhotoVerifyJob.perform_later(photo_id, retries+1)
        else
          puts "Max number of retries #{MAX_RETRIES} reached, giving up"
          EmailNotificationJob.perform_later photo.sender, 'validation_failed', {:title => photo.title}
          photo.delete
        end
        return
      end

      EmailNotificationJob.perform_later(photo.sender, 'validation_ok',
                                         {:title => photo.title,
                                          :id => photo_id})
    rescue => e
      puts e
      puts e.backtrace
    end

  end
end
