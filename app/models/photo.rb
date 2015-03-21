class Photo < ActiveRecord::Base
  has_attached_file :picture,
                    :styles => { :original => "1024x1024>", :thumb => "400x300#", :big => "1024x768>"},
                    :default_url => "/images/:style/missing.png",
                    :convert_options => {
                      :big => ["-bordercolor black","-border 10x10"]
                    }

  validates_attachment_content_type :picture, :content_type => /\Aimage\/.*\Z/
end
