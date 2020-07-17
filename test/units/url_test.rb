# frozen_string_literal: true

require 'test_helper'

class UrlTest < Imgix::Test
  DEMO_IMAGE_PATH = '/images/demo.png'

  def test_signing_with_no_params
    path = client.path(DEMO_IMAGE_PATH)

    assert_equal 'https://demo.imgix.net/images/demo.png?s=2c7c157eaf23b06a0deb2f60b81938c4', path.to_url
  end

  def test_signing_with_one
    path = client.path(DEMO_IMAGE_PATH)

    assert_output(nil, "Warning: `Path.width=' has been deprecated and " \
      "will be removed in the next major version (along " \
      "with all parameter `ALIASES`).\n") {
        path.width = 200
    }

    assert_equal 'https://demo.imgix.net/images/demo.png?w=200&s=da421114ca238d1f4a927b889f67c34e', path.to_url
  end

  def test_signing_with_multiple_params
    path = client.path(DEMO_IMAGE_PATH)

    assert_output(nil, "Warning: `Path.height=' has been deprecated and " \
      "will be removed in the next major version (along " \
      "with all parameter `ALIASES`).\n") {
        path.height = 200
    }

    assert_output(nil, "Warning: `Path.width=' has been deprecated and " \
      "will be removed in the next major version (along " \
      "with all parameter `ALIASES`).\n") {
        path.width = 200
    }

    assert_equal 'https://demo.imgix.net/images/demo.png?h=200&w=200&s=d570a1ecd765470f7b34a69b56718a7a', path.to_url

    path = client.path(DEMO_IMAGE_PATH)

    assert_output(nil, "Warning: `Path.width=' has been deprecated and " \
      "will be removed in the next major version (along " \
      "with all parameter `ALIASES`).\n") {
        path.width = 200
    }

    assert_output(nil, "Warning: `Path.height=' has been deprecated and " \
      "will be removed in the next major version (along " \
      "with all parameter `ALIASES`).\n") {
        path.height = 200
    }

    assert_equal 'https://demo.imgix.net/images/demo.png?w=200&h=200&s=00b5cde5c7b8bca8618cb911da4ac379', path.to_url
  end

  def test_domain_resolves_host_warn
    assert_output(nil, "Warning: The identifier `host' has been deprecated and " \
      "will\nappear as `domain' in the next major version, e.g. " \
      "`@host'\nbecomes `@domain', `options[:host]' becomes " \
      "`options[:domain]'.\n") {
        Imgix::Client.new(host: 'demo.imgix.net', include_library_param: false)
    }


    # Assert the output of this call (to both stdout and stderr) is nil.
    assert_output(nil, nil) {
      Imgix::Client.new(domain: 'demo.imgix.net', include_library_param: false)
    }
  end

private

  def client
    @client ||= Imgix::Client.new(host: 'demo.imgix.net', secure_url_token: '10adc394', include_library_param: false)
  end
end
