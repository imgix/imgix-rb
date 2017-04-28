require 'test_helper'

class DomainsTest < Imgix::Test
  def test_deterministically_choosing_a_path
    client = Imgix::Client.new(hosts: [
        "demos-1.imgix.net",
        "demos-2.imgix.net",
        "demos-3.imgix.net",
      ],
      secure_url_token: '10adc394',
      include_library_param: false)

    path = client.path('/bridge.png')
    assert_equal 'https://demos-1.imgix.net/bridge.png?s=0233fd6de51f20f11cff6b452b7a9a05', path.to_url

    path = client.path('/flower.png')
    assert_equal 'https://demos-2.imgix.net/flower.png?s=02105961388864f85c04121ea7b50e08', path.to_url
  end

  def test_cycling_choosing_domain_in_order
    client = Imgix::Client.new(hosts: [
        "demos-1.imgix.net",
        "demos-2.imgix.net",
        "demos-3.imgix.net",
      ],
      secure_url_token: '10adc394',
      shard_strategy: :cycle,
      include_library_param: false)

    path = client.path('/bridge.png')
    assert_equal 'https://demos-1.imgix.net/bridge.png?s=0233fd6de51f20f11cff6b452b7a9a05', path.to_url

    path = client.path('/bridge.png')
    assert_equal 'https://demos-2.imgix.net/bridge.png?s=0233fd6de51f20f11cff6b452b7a9a05', path.to_url

    path = client.path('/bridge.png')
    assert_equal 'https://demos-3.imgix.net/bridge.png?s=0233fd6de51f20f11cff6b452b7a9a05', path.to_url

    path = client.path('/bridge.png')
    assert_equal 'https://demos-1.imgix.net/bridge.png?s=0233fd6de51f20f11cff6b452b7a9a05', path.to_url
  end

  def test_strips_out_protocol
    client = Imgix::Client.new(host: "http://demos-1.imgix.net",
      secure_url_token: '10adc394',
      include_library_param: false)

    path = client.path('/bridge.png')
    assert_equal 'https://demos-1.imgix.net/bridge.png?s=0233fd6de51f20f11cff6b452b7a9a05', path.to_url
  end

  def test_strips_out_trailing_slash
    client = Imgix::Client.new(host: "http://demos-1.imgix.net/",
      secure_url_token: '10adc394',
      include_library_param: false)

    path = client.path('/bridge.png')
    assert_equal 'https://demos-1.imgix.net/bridge.png?s=0233fd6de51f20f11cff6b452b7a9a05', path.to_url
  end

  def test_with_full_paths
    client = Imgix::Client.new(hosts: [
        "demos-1.imgix.net",
        "demos-2.imgix.net",
        "demos-3.imgix.net",
      ],
      secure_url_token: '10adc394',
      shard_strategy: :cycle,
      include_library_param: false)

    path = 'https://www.example.com/image.png'
    path_escaped = 'https%3A%2F%2Fwww.example.com%2Fimage.png'
    assert_equal "https://demos-1.imgix.net/#{path_escaped}?s=537aa674cbda9339e2b296705733119d", client.path(path).to_url
  end
end
