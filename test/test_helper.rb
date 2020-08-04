# frozen_string_literal: true

require 'rubygems'
require 'bundler'
Bundler.require :test

require 'minitest/autorun'
require 'imgix'
require 'webmock/minitest'

class Imgix::Test < MiniTest::Test
end
