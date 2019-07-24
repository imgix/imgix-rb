# frozen_string_literal: true

require 'imgix/version'
require 'imgix/client'
require 'imgix/path'

module Imgix
  # regex pattern used to determine if a domain is valid
  DOMAIN_REGEX = /^(?:[a-z\d\-_]{1,62}\.){0,125}(?:[a-z\d](?:\-(?=\-*[a-z\d])|[a-z]|\d){0,62}\.)[a-z\d]{1,63}$/i

  # returns an array of width values used during scrset generation
  TARGET_WIDTHS = lambda {
    increment_percentage = 8
    max_size = 8192
    resolutions = []
    prev = 100

    while(prev <= max_size)
      # ensures that each width is even
      resolutions.push((2 * (prev / 2).round))
      prev *= 1 + ((increment_percentage.to_f) / 100) * 2
    end

    resolutions.push(max_size)
    return resolutions
  }
end
