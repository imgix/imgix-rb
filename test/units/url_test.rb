require 'test_helper'

class UrlTest < Imgix::Test
  def test_signing_with_no_params
    path = '/images/demo.png'
    assert_equal 'http://demo.imgix.net/images/demo.png?&s=3c1d676d4daf28c044dd83e8548f834a', client.sign_path(path).to_s
  end

  def test_signing_with_one
    path = '/images/demo.png?w=200'
    assert_equal 'http://demo.imgix.net/images/demo.png?w=200&s=da421114ca238d1f4a927b889f67c34e', client.sign_path(path).to_s
  end

  def test_signing_with_multiple_params
    path = '/images/demo.png?h=200&w=200'
    assert_equal 'http://demo.imgix.net/images/demo.png?h=200&w=200&s=d570a1ecd765470f7b34a69b56718a7a', client.sign_path(path).to_s

    path = '/images/demo.png?w=200&h=200'
    assert_equal 'http://demo.imgix.net/images/demo.png?w=200&h=200&s=00b5cde5c7b8bca8618cb911da4ac379', client.sign_path(path).to_s
  end

private

  def client
    @client ||= Imgix::Client.new(:host => 'demo.imgix.net', :token => '10adc394')
  end
end
