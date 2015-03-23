class AddPictureProcessingToPhoto < ActiveRecord::Migration

  def self.up
    add_column :photos, :picture_processing, :boolean
  end

  def self.down
    remove_column :photos, :picture_processing
  end

end
