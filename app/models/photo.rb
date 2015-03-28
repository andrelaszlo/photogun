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

  after_post_process :post_process_finished

  def post_process_finished(*args)
    # Unfortunately the after_post_process seems to run before post processing
    # is actually finished, if delayed paperclip is used. This job will verify
    # that the picture is uploaded to S3 correctly, otherwise the photo will be
    # deleted.
    PhotoVerifyJob.perform_later self.id, 0
  end
end
