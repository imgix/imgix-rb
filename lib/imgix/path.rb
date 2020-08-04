# frozen_string_literal: true

require 'base64'
require 'cgi/util'
require 'erb'
require 'imgix/param_helpers'

module Imgix
  class Path
    include ParamHelpers

    ALIASES = {
      width: :w,
      height: :h,
      rotation: :rot,
      noise_reduction: :nr,
      sharpness: :sharp,
      exposure: :exp,
      vibrance: :vib,
      saturation: :sat,
      brightness: :bri,
      contrast: :con,
      highlight: :high,
      shadow: :shad,
      gamma: :gam,
      pixelate: :px,
      halftone: :htn,
      watermark: :mark,
      text: :txt,
      format: :fm,
      quality: :q
    }.freeze

    def initialize(prefix, secure_url_token, path = '/')
      @prefix = prefix
      @secure_url_token = secure_url_token
      @path = path
      @options = {}

      @path = CGI.escape(@path) if /^https?/ =~ @path
      @path = "/#{@path}" if @path[0] != '/'
      @target_widths = TARGET_WIDTHS.call(DEFAULT_WIDTH_TOLERANCE, MIN_WIDTH, MAX_WIDTH)
    end

    def to_url(opts = {})
      prev_options = @options.dup
      @options.merge!(opts)

      url = @prefix + path_and_params

      if @secure_url_token
        url += (has_query? ? '&' : '?') + "s=#{signature}"
      end

      @options = prev_options
      url
    end

    def defaults
      @options = {}
      self
    end

    def method_missing(method, *args, &block)
      key = method.to_s.gsub('=', '')
      if args.length == 0
        return @options[key]
      elsif args.first.nil? && @options.has_key?(key)
        @options.delete(key) and return self
      end

      @options[key] = args.join(',')
      self
    end

    ALIASES.each do |from, to|
      define_method from do |*args|
        warn "Warning: `Path.#{from}' has been deprecated and " \
             "will be removed in the next major version (along " \
             "with all parameter `ALIASES`).\n"
        self.send(to, *args)
      end

      define_method "#{from}=" do |*args|
        warn "Warning: `Path.#{from}=' has been deprecated and " \
             "will be removed in the next major version (along " \
             "with all parameter `ALIASES`).\n"
        self.send("#{to}=", *args)
        return self
      end
    end

    def to_srcset(options: {}, **params)
      prev_options = @options.dup
      @options.merge!(params)

      width = @options[:w]
      height = @options[:h]
      aspect_ratio = @options[:ar]

      srcset = if width || (height && aspect_ratio)
                 build_dpr_srcset(options: options, params: @options)
               else
                 build_srcset_pairs(options: options, params: @options)
               end

      @options = prev_options
      srcset
    end

    private

    def signature
      Digest::MD5.hexdigest(@secure_url_token + path_and_params)
    end

    def path_and_params
      has_query? ? "#{@path}?#{query}" : @path
    end

    def query
      @options.map do |key, val|
        escaped_key = ERB::Util.url_encode(key.to_s)

        if escaped_key.end_with? '64'
          escaped_key << "=" << Base64.urlsafe_encode64(val.to_s).delete('=')
        else
          escaped_key << "=" << ERB::Util.url_encode(val.to_s)
        end
      end.join('&')
    end

    def has_query?
      query.length > 0
    end

    def build_srcset_pairs(options:, params:)
      srcset = ''

      widths = options[:widths] || []
      width_tolerance = options[:width_tolerance] || DEFAULT_WIDTH_TOLERANCE
      min_width = options[:min_width] || MIN_WIDTH
      max_width = options[:max_width] || MAX_WIDTH

      if !widths.empty?
        validate_widths!(widths)
        srcset_widths = widths
      elsif width_tolerance != DEFAULT_WIDTH_TOLERANCE || min_width != MIN_WIDTH || max_width != MAX_WIDTH
        validate_range!(min_width, max_width)
        validate_width_tolerance!(width_tolerance)
        srcset_widths = TARGET_WIDTHS.call(width_tolerance, min_width, max_width)
      else
        srcset_widths = @target_widths
      end

      srcset_widths.each do |width|
        params[:w] = width
        srcset += "#{to_url(params)} #{width}w,\n"
      end

      srcset[0..-3]
    end

    def build_dpr_srcset(options:, params:)
      srcset = ''

      disable_variable_quality = options[:disable_variable_quality] || false
      validate_variable_qualities!(disable_variable_quality)

      target_ratios = [1, 2, 3, 4, 5]
      quality = params[:q]

      target_ratios.each do |ratio|
        params[:dpr] = ratio

        unless disable_variable_quality
          params[:q] = quality || DPR_QUALITY[ratio]
        end

        srcset += "#{to_url(params)} #{ratio}x,\n"
      end

      srcset[0..-3]
    end

    def validate_width_tolerance!(width_tolerance)
      width_increment_error = 'error: `width_tolerance` must be a positive `Numeric` value'

      if !width_tolerance.is_a?(Numeric) || width_tolerance <= 0
        raise ArgumentError, width_increment_error
      end
    end

    def validate_widths!(widths)
      widths_error = 'error: `widths` must be an array of positive `Numeric` values'
      raise ArgumentError, widths_error unless widths.is_a?(Array)

      all_positive_integers = widths.all? { |i| i.is_a?(Integer) && i > 0 }
      raise ArgumentError, widths_error unless all_positive_integers
    end

    def validate_range!(min_srcset, max_srcset)
      range_numeric_error = 'error: `min_width` and `max_width` must be positive `Numeric` values'
      unless min_srcset.is_a?(Numeric) && max_srcset.is_a?(Numeric)
        raise ArgumentError, range_numeric_error
      end

      unless min_srcset > 0 && max_srcset > 0
        raise ArgumentError, range_numeric_error
      end
    end

    def validate_variable_qualities!(disable_quality)
      disable_quality_error = 'error: `disable_quality` must be a Boolean value'
      unless disable_quality.is_a?(TrueClass) || disable_quality.is_a?(FalseClass)
        raise ArgumentError, disable_quality_error
      end
    end
  end
end
