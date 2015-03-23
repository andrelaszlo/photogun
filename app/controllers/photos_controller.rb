class PhotosController < ApplicationController
  def index
    @photos = Photo.where(:picture_processing => false).order(:created_at => :desc).limit(99)
  end

  def show
    @photo = Photo.find(params[:id])
  end
end
