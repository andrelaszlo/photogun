class PhotosController < ApplicationController
  def index
    @photos = Photo.order(created_at: :desc).first(99)
    until @photos.length % 3 == 0
      @photos.pop
    end
    @photos
  end

  def show
    @photo = Photo.find(params[:id])
  end
end
