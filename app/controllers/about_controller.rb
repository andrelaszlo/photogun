class AboutController < ApplicationController
  def index
    @upload_email = ENV['PHOTOGUN_UPLOAD_EMAIL'] || 'upload@mailgun.example.com'
  end
end
