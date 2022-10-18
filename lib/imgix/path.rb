# frozen_string_literal: true

require "base64"
require "cgi/util"
require "erb"

module Imgix
  class Path

    def initialize(prefix, secure_url_token, path = "/")
      @prefix = prefix
      @secure_url_token = secure_url_token
      @path = path
      @options = {}
    end

    def to_url(params = {}, options = {})
      sanitized_path = sanitize_path(@path, options)
      prev_options = @options.dup
      @options.merge!(params)

      current_path_and_params = path_and_params(sanitized_path)
      url = @prefix + current_path_and_params

      if @secure_url_token
        url += (has_query? ? "&" : "?") + "s=#{signature(current_path_and_params)}"
      end

      @options = prev_options
      url
    end

    def defaults
      @options = {}
      self
    end

    def ixlib(lib_version)
      @options[:ixlib] = lib_version
    end

    def ixlib=(lib_version)
      @options[:ixlib] = lib_version
    end

    def to_srcset(options: {}, **params)
      prev_options = @options.dup
      @options.merge!(params)

      width = @options[:w]
      height = @options[:h]
      aspect_ratio = @options[:ar]

      srcset = if width || height
          build_dpr_srcset(options: options, params: @options)
        else
          build_srcset_pairs(options: options, params: @options)
        end

      @options = prev_options
      srcset
    end

    ALIASES = {
      width:           :w,
      height:          :h,
      rotation:        :rot,
      noise_reduction: :nr,
      sharpness:       :sharp,
      exposure:        :exp,
      vibrance:        :vib,
      saturation:      :sat,
      brightness:      :bri,
      contrast:        :con,
      highlight:       :high,
      shadow:          :shad,
      gamma:           :gam,
      pixelate:        :px,
      halftone:        :htn,
      watermark:       :mark,
      text:            :txt,
      format:          :fm,
      quality:         :q,
      fill_color:      :fillcolor
    }.freeze

    # Define query parameters on a Path (via method_missing).
    # Normally, when overriding method_missing, it is a best practice
    # to fall back to super, but this method works differently.
    #
    # method_missing intercepts messages sent to objects of this class
    # and acts as a getter, setter, and deleter. If there are no args,
    # e.g. `path.width`, then this method acts like a getter.
    #
    # Likewise, if the first argument is nil and the method name exists
    # as a key in @options, e.g. `path.param_name = nil`, then this
    # method acts like a deleter and the `param_name` is removed from
    # the list of @options.
    #
    # Finally, in _all_ other cases, the `method` name is used as the
    # `key` and the `*args` are used as the value.
    def method_missing(method, *args, &block)
      key = method.to_s.gsub('=', '')

      if args.length == 0 # Get, or
        return @options[key]
      elsif args.first.nil? && @options.has_key?(key) # Delete, or
        @options.delete(key) and return self
      end

      @options[key] = args.join(',') # Set the option.
      self
    end

    # Use ALIASES to define setters for a subset of imgix parameters.
    # E.g. `path.width(100)` would result in `send(:w, [100])`.
    ALIASES.each do |from, to|
      define_method from do |*args|
        self.send(to, *args)
      end

      # E.g. `path.width = 100` would result in `send(":w=", [100])`.
      define_method "#{from}=" do |*args|
        self.send("#{to}=", *args)
        return self
      end
    end

    private

    # Escape and encode any characters in path that are reserved and not utf8 encoded.
    # This includes " +?:#" characters. If a path is being used as a proxy, utf8
    # encode everything. If it is not being used as proxy, leave certain chars, like
    # "/", alone. Method assumes path is not already encoded.
    def sanitize_path(path, options = {})
      # remove the leading "/", we'll add it back after encoding
      path = path.slice(1, path.length) if Regexp.new('^/') =~ path
      if options[:disable_path_encoding]
        return "/" + path
      # if path is being used as a proxy, encode the entire thing
      elsif /^https?/ =~ path
        return encode_URI_Component(path)
      else
        # otherwise, encode only specific characters
        return encode_URI(path)
      end
    end

    # URL encode the entire path
    def encode_URI_Component(path)
      return "/" + ERB::Util.url_encode(path)
    end

    # URL encode every character in the path, including
    # " +?:#" characters.
    def encode_URI(path)
      # For each component in the path, URL encode it and add it
      # to the array path component.
      path_components = []
      path.split("/").each do |str|
        path_components << ERB::Util.url_encode(str)
      end
      # Prefix and join the encoded path components.
      "/#{path_components.join('/')}"
    end

    def signature(rest)
      Digest::MD5.hexdigest(@secure_url_token + rest)
    end

    def path_and_params(path)
      has_query? ? "#{path}?#{query}" : path
    end

    def query
      @options.map do |key, val|
        escaped_key = ERB::Util.url_encode(key.to_s)

        if escaped_key.end_with? '64'
          escaped_key << "=" << Base64.urlsafe_encode64(val.to_s).delete('=')
        else
          escaped_key << "=" << ERB::Util.url_encode(val.to_s)
        end
      end.join("&")
    end

    def has_query?
      !query.empty?
    end

    def build_srcset_pairs(options:, params:)
      srcset = ""

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
        srcset_widths = DEFAULT_TARGET_WIDTHS
      end

      srcset_widths.each do |width|
        params[:w] = width
        srcset += "#{to_url(params, options)} #{width}w,\n"
      end

      srcset[0..-3]
    end

    def build_dpr_srcset(options:, params:)
      srcset = ""

      disable_variable_quality = options[:disable_variable_quality] || false
      validate_variable_qualities!(disable_variable_quality)

      target_ratios = [1, 2, 3, 4, 5]
      quality = params[:q]

      target_ratios.each do |ratio|
        params[:dpr] = ratio

        params[:q] = quality || DPR_QUALITY[ratio] unless disable_variable_quality

        srcset += "#{to_url(params, options)} #{ratio}x,\n"
      end

      srcset[0..-3]
    end

    def validate_width_tolerance!(width_tolerance)
      width_increment_error = "error: `width_tolerance` must be a positive `Numeric` value"

      raise ArgumentError, width_increment_error if !width_tolerance.is_a?(Numeric) || width_tolerance <= 0
    end

    def validate_widths!(widths)
      widths_error = "error: `widths` must be an array of positive `Numeric` values"
      raise ArgumentError, widths_error unless widths.is_a?(Array)

      all_positive_integers = widths.all? { |i| i.is_a?(Integer) && i > 0 }
      raise ArgumentError, widths_error unless all_positive_integers
    end

    def validate_range!(min_width, max_width)
      range_numeric_error = "error: `min_width` and `max_width` must be positive `Numeric` values"
      raise ArgumentError, range_numeric_error unless min_width.is_a?(Numeric) && max_width.is_a?(Numeric)

      raise ArgumentError, range_numeric_error unless min_width > 0 && max_width > 0
    end

    def validate_variable_qualities!(disable_quality)
      disable_quality_error = "error: `disable_quality` must be a Boolean value"
      unless disable_quality.is_a?(TrueClass) || disable_quality.is_a?(FalseClass)
        raise ArgumentError, disable_quality_error
      end
    end
  end
end
