# frozen_string_literal: true

require 'imgix/version'
require 'imgix/client'
require 'imgix/path'

module Imgix
  DOMAIN_REGEX = /^(?:[a-z\d\-_]{1,62}\.){0,125}(?:[a-z\d](?:\-(?=\-*[a-z\d])|[a-z]|\d){0,62}\.)[a-z\d]{1,63}$/i
end
