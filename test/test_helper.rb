# frozen_string_literal: true

require "rubygems"
require "bundler"
Bundler.require :test

require "minitest/autorun"
require "imgix"
require "webmock/minitest"
require "minitest/reporters"

Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new

class Imgix::Test < MiniTest::Test
end
