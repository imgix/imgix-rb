# frozen_string_literal: true

require 'test_helper'

class DomainsTest < Imgix::Test
  def test_valid_port_on_domain
    Imgix::Client.new(domain: "localhost.me:3000")
  end

  def test_invalid_domain_append_slash
    assert_raises(ArgumentError) {Imgix::Client.new(domain: "assets.imgix.net/")}
  end

  def test_invalid_domain_prepend_scheme
    assert_raises(ArgumentError) {Imgix::Client.new(domain: "https://assets.imgix.net")}
  end

  def test_invalid_domain_append_dash
    assert_raises(ArgumentError) {Imgix::Client.new(domain: "assets.imgix.net-")}
  end
end
