require 'test_helper'

class DomainsTest < Imgix::Test

  def test_deterministically_choosing_a_path
    client = Imgix::Client.new(:host => [
        "demos-1.imgix.net",
        "demos-2.imgix.net",
        "demos-3.imgix.net",
      ],
      :token => '10adc394')

    path = client.path('/bridge.png')
    assert_equal 'http://demos-1.imgix.net/bridge.png?&s=13e68f249172e5f790344e85e7cdb14b', path.to_url

    path = client.path('/flower.png')
    assert_equal 'http://demos-2.imgix.net/flower.png?&s=7793669cc41d31fd21c26ede9709ef03', path.to_url
  end

  def test_cycling_choosing_domain_in_order
    client = Imgix::Client.new(:host => [
        "demos-1.imgix.net",
        "demos-2.imgix.net",
        "demos-3.imgix.net",
      ],
      :token => '10adc394',
      :shard_strategy => :cycle)

    path = client.path('/bridge.png')
    assert_equal 'http://demos-1.imgix.net/bridge.png?&s=13e68f249172e5f790344e85e7cdb14b', path.to_url

    path = client.path('/bridge.png')
    assert_equal 'http://demos-2.imgix.net/bridge.png?&s=13e68f249172e5f790344e85e7cdb14b', path.to_url

    path = client.path('/bridge.png')
    assert_equal 'http://demos-3.imgix.net/bridge.png?&s=13e68f249172e5f790344e85e7cdb14b', path.to_url

    path = client.path('/bridge.png')
    assert_equal 'http://demos-1.imgix.net/bridge.png?&s=13e68f249172e5f790344e85e7cdb14b', path.to_url

  end

end
