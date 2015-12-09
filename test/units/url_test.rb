require 'test_helper'

class UrlTest < Imgix::Test
  DEMO_IMAGE_PATH = '/images/demo.png'

  def test_signing_with_no_params
    path = client.path(DEMO_IMAGE_PATH)

    assert_equal 'https://demo.imgix.net/images/demo.png?&s=3c1d676d4daf28c044dd83e8548f834a', path.to_url
  end

  def test_signing_with_one
    path = client.path(DEMO_IMAGE_PATH)
    path.width = 200

    assert_equal 'https://demo.imgix.net/images/demo.png?w=200&s=da421114ca238d1f4a927b889f67c34e', path.to_url
  end

  def test_signing_with_multiple_params
    path = client.path(DEMO_IMAGE_PATH)
    path.height = 200
    path.width = 200
    assert_equal 'https://demo.imgix.net/images/demo.png?h=200&w=200&s=d570a1ecd765470f7b34a69b56718a7a', path.to_url

    path = client.path(DEMO_IMAGE_PATH)
    path.width = 200
    path.height = 200
    assert_equal 'https://demo.imgix.net/images/demo.png?w=200&h=200&s=00b5cde5c7b8bca8618cb911da4ac379', path.to_url
  end

private

  def client
    @client ||= Imgix::Client.new(host: 'demo.imgix.net', secure_url_token: '10adc394', include_library_param: false)
  end
end
