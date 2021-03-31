# frozen_string_literal: true

require "imgix/version"
require "imgix/client"
require "imgix/path"
require "imgix/variant"

module Imgix
  # regex pattern used to determine if a domain is valid
  DOMAIN_REGEX = /^(?:[a-z\d\-_]{1,62}\.){0,125}(?:[a-z\d](?:\-(?=\-*[a-z\d])|[a-z]|\d){0,62}\.)[a-z\d]{1,63}$/i.freeze

  # determines the growth rate when building out srcset pair widths
  DEFAULT_WIDTH_TOLERANCE = 0.08

  # the default minimum srcset width
  MIN_WIDTH = 100

  # the default maximum srcset width, also the max width supported by imgix
  MAX_WIDTH = 8192

  # returns an array of width values used during scrset generation
  TARGET_WIDTHS = lambda { |tolerance, min, max|
    increment_percentage = tolerance || DEFAULT_WIDTH_TOLERANCE

    unless increment_percentage.is_a?(Numeric) && increment_percentage > 0
      width_increment_error = "error: `width_tolerance` must be a positive `Numeric` value"
      raise ArgumentError, width_increment_error
    end

    max_size = max || MAX_WIDTH
    resolutions = []
    prev = min || MIN_WIDTH

    while prev < max_size
      # ensures that each width is even
      resolutions.push(prev.round)
      prev *= 1 + (increment_percentage * 2)
    end

    resolutions.push(max_size)
    return resolutions
  }

  # hash of default quality parameter values mapped  by each dpr srcset entry
  DPR_QUALITY = {
    1 => 75,
    2 => 50,
    3 => 35,
    4 => 23,
    5 => 20
  }.freeze

  def self.escape_query_string(options)
    options.map do |key, val|
      escaped_key = ERB::Util.url_encode(key.to_s)

      if escaped_key.end_with? '64'
        escaped_key << "=" << Base64.urlsafe_encode64(val.to_s).delete('=')
      else
        escaped_key << "=" << ERB::Util.url_encode(val.to_s)
      end
    end.join("&")
  end
end
