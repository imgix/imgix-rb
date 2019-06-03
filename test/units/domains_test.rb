# frozen_string_literal: true

require 'test_helper'

class DomainsTest < Imgix::Test
  def test_invalid_domain_append_slash
    assert_raises(ArgumentError) {Imgix::Client.new(host: "assets.imgix.net/")}
  end

  def test_invalid_domain_prepend_scheme
    assert_raises(ArgumentError) {Imgix::Client.new(host: "https://assets.imgix.net")}
  end

  def test_invalid_domain_append_dash
    assert_raises(ArgumentError) {Imgix::Client.new(host: "assets.imgix.net-")}
  end
end
