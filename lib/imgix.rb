# frozen_string_literal: true

require 'imgix/version'
require 'imgix/client'
require 'imgix/path'

module Imgix
  # regex pattern used to determine if a domain is valid
  DOMAIN_REGEX = /^(?:[a-z\d\-_]{1,62}\.){0,125}(?:[a-z\d](?:\-(?=\-*[a-z\d])|[a-z]|\d){0,62}\.)[a-z\d]{1,63}$/i

  # determines the growth rate when building out srcset pair widths
  DEFAULT_WIDTH_TOLERANCE = 0.08

  # the default minimum srcset width
  MIN_WIDTH = 100

  # the default maximum srcset width, also the max width supported by imgix
  MAX_WIDTH = 8192
  # returns an array of width values used during scrset generation
  TARGET_WIDTHS = lambda { |tolerance|
    increment_percentage = tolerance || DEFAULT_WIDTH_TOLERANCE
    unless increment_percentage.is_a? Numeric and increment_percentage > 0
      raise ArgumentError, "The width_tolerance argument must be passed a positive scalar value"
    end

    max_size = 8192
    resolutions = []
    prev = 100

    while(prev <= max_size)
      # ensures that each width is even
      resolutions.push((2 * (prev / 2).round))
      prev *= 1 + (increment_percentage * 2)
    end

    resolutions.push(max_size)
    return resolutions
  }
end
