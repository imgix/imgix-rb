require 'test_helper'

class DomainsTest < Imgix::Test

  def test_deterministically_choosing_a_path
    client = Imgix::Client.new(:hosts => [
        "demos-1.imgix.net",
        "demos-2.imgix.net",
        "demos-3.imgix.net",
      ],
      :token => '10adc394')

    path = client.path('/bridge.png')
    assert_equal 'http://demos-1.imgix.net/bridge.png', path.to_url

    path = client.path('/flower.png')
    assert_equal 'http://demos-2.imgix.net/flower.png', path.to_url
  end

  def test_cycling_choosing_domain_in_order
    client = Imgix::Client.new(:hosts => [
        "demos-1.imgix.net",
        "demos-2.imgix.net",
        "demos-3.imgix.net",
      ],
      :token => '10adc394',
      :shard_strategy => :cycle)

    path = client.path('/bridge.png')
    assert_equal 'http://demos-1.imgix.net/bridge.png', path.to_url

    path = client.path('/bridge.png')
    assert_equal 'http://demos-2.imgix.net/bridge.png', path.to_url

    path = client.path('/bridge.png')
    assert_equal 'http://demos-3.imgix.net/bridge.png', path.to_url

    path = client.path('/bridge.png')
    assert_equal 'http://demos-1.imgix.net/bridge.png', path.to_url

  end

  def test_strips_out_protocol
    client = Imgix::Client.new(:host =>
        "http://demos-1.imgix.net",
        :token => '10adc394')

    path = client.path('/bridge.png')
    assert_equal 'http://demos-1.imgix.net/bridge.png', path.to_url

  end

end
