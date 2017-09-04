require 'test_helper'

class UrlTest < Imgix::Test
  DEMO_IMAGE_PATH = '/images/demo.png'
  DEMO_URL_WITH_SPACE_PATH = 'https://google.com/images/demo file.png'

  def test_signing_with_unescaped_full_url_with_spaces
    path = client.path(DEMO_URL_WITH_SPACE_PATH)
    path.height = 200
    path.width = 200
    assert_equal 'https://demo.imgix.net/https%3A%2F%2Fgoogle.com%2Fimages%2Fdemo%20file.png?h=200&w=200&s=12a58ca5a6a54d89bcded0af1e32d398', path.to_url
  end

  def test_signing_with_no_params
    path = client.path(DEMO_IMAGE_PATH)

    assert_equal 'https://demo.imgix.net/images/demo.png?s=2c7c157eaf23b06a0deb2f60b81938c4', path.to_url
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
