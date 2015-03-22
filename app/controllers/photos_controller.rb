class PhotosController < ApplicationController
  def index
    @photos = Photo.order(created_at: :desc).first(99)
  end

  def show
    @photo = Photo.find(params[:id])
  end
end
