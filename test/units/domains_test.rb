# frozen_string_literal: true

require 'test_helper'

class DomainsTest < Imgix::Test
  def test_deterministically_choosing_a_path
    assert_output(nil, "Warning: Domain sharding has been deprecated and will be removed in the next major version.\n"){
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
    }
  end

  def test_cycling_choosing_domain_in_order
    assert_output(nil, "Warning: Domain sharding has been deprecated and will be removed in the next major version.\n"){
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
    }
  end

  def test_with_full_paths
    assert_output(nil, "Warning: Domain sharding has been deprecated and will be removed in the next major version.\n"){
      client = Imgix::Client.new(hosts: [
          "demos-1.imgix.net",
          "demos-2.imgix.net",
          "demos-3.imgix.net",
        ],
        secure_url_token: '10adc394',
        shard_strategy: :cycle,
        include_library_param: false)

      path = 'https://google.com/cats.gif'
      assert_equal "https://demos-1.imgix.net/#{CGI.escape(path)}?s=e686099fbba86fc2b8141d3c1ff60605", client.path(path).to_url
    }
  end

  def test_invalid_domain_append_slash
    assert_raises(ArgumentError) {Imgix::Client.new(hosts: "assets.imgix.net/")}
  end

  def test_invalid_domain_prepend_scheme
    assert_raises(ArgumentError) {Imgix::Client.new(hosts: "https://assets.imgix.net")}
  end

  def test_invalid_domain_append_dash
    assert_raises(ArgumentError) {Imgix::Client.new(hosts: "assets.imgix.net-")}
  end

  def test_domain_sharding_deprecation_host

    assert_output(nil, "Warning: Domain sharding has been deprecated and will be removed in the next major version.\n"){
      Imgix::Client.new(host: ["assets1.imgix.net", "assets2.imgix.net"])
    }
  end

  def test_domain_sharding_deprecation_hosts
    assert_output(nil, "Warning: Domain sharding has been deprecated and will be removed in the next major version.\n"){
      Imgix::Client.new(hosts: ["assets1.imgix.net", "assets2.imgix.net"])
    }
  end
end
