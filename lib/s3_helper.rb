require 'aws-sdk'
require 'uri'

# Provide object count for Paperclip's S3 storage
class S3Helper
  def initialize
    secrets = Rails.application.secrets
    AWS.config(access_key_id: secrets.aws_access_key_id,
               secret_access_key: secrets.aws_secret_access_key)
    s3 = AWS::S3.new
    @bucket = s3.buckets[secrets.s3_bucket_name]
  end

  # Return the number of objects for a Paperclip url
  def count_objects(url)
    @bucket.objects.with_prefix(key url).count
  end

  private
  def key(url)
    # '/mybucket/photos/pictures/000/000/123/original/foo.jpg' => 'photos/pictures/000/000/123'
    # Removing the leading '/mybucket/' and the trailing '/original/foo.jpg'
    URI(url).path.split('/')[2..-3].join('/')
  end
end
