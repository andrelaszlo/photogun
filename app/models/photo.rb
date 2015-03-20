class Photo < ActiveRecord::Base
  has_attached_file :picture, :styles => { :thumb => "400x300#" }, :default_url => "/images/:style/missing.png"
  validates_attachment_content_type :picture, :content_type => /\Aimage\/.*\Z/
end
