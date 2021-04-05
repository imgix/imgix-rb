# frozen_string_literal: true

require "rubygems"
require "bundler"
Bundler.require :test

require "minitest/autorun"
require "imgix"
require "webmock/minitest"

require 'minitest/autorun'
require 'minitest/reporters' # requires the gem

Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new

class Imgix::Test < MiniTest::Test
end
