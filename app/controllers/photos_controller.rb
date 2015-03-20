class PhotosController < ApplicationController
  def index
    @photos = Photo.order(created_at: :desc).first(10)
  end
end
