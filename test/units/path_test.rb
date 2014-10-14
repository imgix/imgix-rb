require 'test_helper'

class PathTest < Imgix::Test
  def test_creating_a_path
    path = client.path('/images/demo.png')
    assert_equal 'http://demo.imgix.net/images/demo.png', path.to_url

    path = client.path('images/demo.png')
    assert_equal 'http://demo.imgix.net/images/demo.png', path.to_url
  end

  def test_path_with_param
    url = 'http://demo.imgix.net/images/demo.png?w=200'
    path = client.path('/images/demo.png')
    path.width = 200

    assert_equal url, path.to_url

    path = client.path('/images/demo.png')
    assert_equal url, path.to_url(w: 200)

    path = client.path('/images/demo.png')
    assert_equal url, path.width(200).to_url
  end

  def test_creating_a_signed_path
    path = client.sign_path('/images/demo.png')
    assert_equal 'http://demo.imgix.net/images/demo.png?&s=3c1d676d4daf28c044dd83e8548f834a', path.to_url

    path = client.sign_path('images/demo.png')
    assert_equal 'http://demo.imgix.net/images/demo.png?&s=3c1d676d4daf28c044dd83e8548f834a', path.to_url
  end

  def test_signing_path_with_param
    url = 'http://demo.imgix.net/images/demo.png?w=200&s=da421114ca238d1f4a927b889f67c34e'
    path = client.sign_path('/images/demo.png')
    path.width = 200

    assert_equal url, path.to_url

    path = client.sign_path('/images/demo.png')
    assert_equal url, path.to_url(w: 200)

    path = client.sign_path('/images/demo.png')
    assert_equal url, path.width(200).to_url
  end

  def test_resetting_defaults
    url = 'http://demo.imgix.net/images/demo.png?w=200'
    path = client.path('/images/demo.png')
    path.height = 300

    assert_equal url, path.defaults.to_url(w: 200)
  end

  def test_path_with_multiple_params
    url = 'http://demo.imgix.net/images/demo.png?h=200&w=200'
    path = client.path('/images/demo.png')

    assert_equal url, path.to_url(h: 200, w: 200)

    path = client.path('/images/demo.png')
    assert_equal url, path.height(200).width(200).to_url
  end

  def test_host_is_required
    assert_raises(ArgumentError) {Imgix::Client.new}
  end

  private

  def client
    @client ||= Imgix::Client.new(:host => 'demo.imgix.net', :token => '10adc394')
  end
end
