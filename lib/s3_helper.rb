require 'aws-sdk'
require 'uri'

# Provide object count for Paperclip's S3 storage
class S3Helper
  def initialize
    AWS.config access_key_id: ENV['AWS_ACCESS_KEY_ID'], secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']
    s3 = AWS::S3.new
    @bucket = s3.buckets[ENV['S3_BUCKET_NAME']]
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
