class Photo < ActiveRecord::Base
  border_color = "#27292B"
  has_attached_file :picture,
                    :styles => { :original => "1024x1024>", :thumb => "400x300#", :big => "1024x768>"},
                    :default_url => "/images/:style/missing.png",
                    :convert_options => {
                      :big => ["-coalesce", "-bordercolor '#{border_color}'", "-border 10x10"]
                    }

  validates :picture, :attachment_presence => true
  validates_attachment_content_type :picture, :content_type => /\Aimage\/.*\Z/
  validates_with AttachmentPresenceValidator, :attributes => :picture

  process_in_background :picture

  # Check if the photo should show up in the gallery
  def completed?
    !self.picture_processing? && self.delayed_processing_ok
  end

  def validate!
    expected_count = Photo.attachment_definitions[:picture][:styles].count

    # The validations seem to be half-broken for Delayed Paperclip so check
    # that the expected objects were saved in S3
    s3 = S3Helper.new
    count = s3.count_objects self.picture.url

    if count < expected_count
      puts "#{count} out of #{expected_count} styles were saved"
      return false
    end

    puts "#{count}/#{expected_count} styles saved"
    self.delayed_processing_ok = true
    self.save

    true
  end
end
