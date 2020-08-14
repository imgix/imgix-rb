# frozen_string_literal: true

require "test_helper"

class UrlTest < Imgix::Test
  DEMO_IMAGE_PATH = "/images/demo.png"

  def test_signing_with_no_params
    path = client.path(DEMO_IMAGE_PATH)
    expected = "https://demo.imgix.net/images/demo.png?s=2c7c157eaf23b06a0deb2f60b81938c4"

    assert_equal expected, path.to_url
  end

  def test_signing_with_one
    path = client.path(DEMO_IMAGE_PATH)
    expected = "https://demo.imgix.net/images/demo.png?w=200&s=da421114ca238d1f4a927b889f67c34e"

    assert_equal expected, path.to_url(w: 200)
  end

  def test_signing_with_multiple_params
    path = client.path(DEMO_IMAGE_PATH)
    expected = "https://demo.imgix.net/images/demo.png?h=200&w=200&s=d570a1ecd765470f7b34a69b56718a7a"

    assert_equal expected, path.to_url(h: 200, w: 200)
  end

  private

  def client
    @client ||= Imgix::Client.new(
      domain: "demo.imgix.net",
      secure_url_token: "10adc394",
      include_library_param: false
    )
  end
end
