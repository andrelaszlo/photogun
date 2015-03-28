class AddDelayedProcessingOkToPhoto < ActiveRecord::Migration
  def self.up
    add_column :photos, :delayed_processing_ok, :boolean, default: false
  end

  def self.down
    remove_column :photos, :delayed_processing_ok
  end
end
