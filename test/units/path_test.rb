require 'test_helper'

class PathTest < Imgix::Test
  def test_creating_a_path
    path = client.path('/images/demo.png')
    assert_equal 'http://demo.imgix.net/images/demo.png?&s=3c1d676d4daf28c044dd83e8548f834a', path.to_url

    path = client.path('images/demo.png')
    assert_equal 'http://demo.imgix.net/images/demo.png?&s=3c1d676d4daf28c044dd83e8548f834a', path.to_url
  end

  def test_signing_path_with_param
    url = 'http://demo.imgix.net/images/demo.png?w=200&s=da421114ca238d1f4a927b889f67c34e'
    path = client.path('/images/demo.png')
    path.width = 200

    assert_equal url, path.to_url

    path = client.path('/images/demo.png')
    assert_equal url, path.to_url(w: 200)

    path = client.path('/images/demo.png')
    assert_equal url, path.width(200).to_url
  end

  def test_resetting_defaults
    url = 'http://demo.imgix.net/images/demo.png?w=200&s=da421114ca238d1f4a927b889f67c34e'
    path = client.path('/images/demo.png')
    path.height = 300

    assert_equal url, path.defaults.to_url(w: 200)
  end

  def test_path_with_multiple_params
    url = 'http://demo.imgix.net/images/demo.png?h=200&w=200&s=d570a1ecd765470f7b34a69b56718a7a'
    path = client.path('/images/demo.png')

    assert_equal url, path.to_url(h: 200, w: 200)

    path = client.path('/images/demo.png')
    assert_equal url, path.height(200).width(200).to_url
  end

  def test_path_with_multi_value_param_safely_encoded
    url = 'http://demo.imgix.net/images/demo.png?markalign=middle%2Ccenter&s=f0d0e28a739f022638f4ba6dddf9b694'
    path = client.path('/images/demo.png')

    assert_equal url, path.markalign('middle', 'center').to_url
  end

  def test_host_is_required
    assert_raises(ArgumentError) {Imgix::Client.new}
  end

  def test_token_is_optional
    client = Imgix::Client.new(host: 'demo.imgix.net')
    url = 'http://demo.imgix.net/images/demo.png?'
    path = client.path('/images/demo.png')

    assert_equal url, path.to_url
  end

  private

  def client
    @client ||= Imgix::Client.new(:host => 'demo.imgix.net', :token => '10adc394')
  end
end
