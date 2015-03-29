class S3HelperTest < ActionController::TestCase
  test "count_objects" do
    example_collection = ['1', '2', '3']
    expected_count = 3

    example_url = 'https://example.com/mybucket/photos/pictures/000/000/123/original/foo.jpg?12345'
    expected_key = 'photos/pictures/000/000/123'

    collection = mock()
    bucket = mock()
    buckets = mock()
    s3 = mock()

    AWS::S3.stubs(:new).returns(s3)
    s3.stubs(:buckets).returns(buckets)
    buckets.stubs(:[]).returns(bucket)
    bucket.stubs(:objects).returns(collection)
    collection.expects(:with_prefix).with(expected_key).once.returns(example_collection)


    assert_equal 3, S3Helper.new.count_objects(example_url)
  end
end
