# frozen_string_literal: true

require 'base64'
require 'cgi/util'
require 'erb'
require 'imgix/param_helpers'

module Imgix
  class Path
    include ParamHelpers

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
      quality:         :q
    }

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
        self.send(to, *args)
      end

      define_method "#{from}=" do |*args|
        self.send("#{to}=", *args)
        return self
      end
    end

    def to_srcset(options: {}, **params)
      prev_options = @options.dup
      @options.merge!(params)

      width = @options['w'.to_sym]
      height = @options['h'.to_sym]
      aspect_ratio = @options['ar'.to_sym]

      if ((width) || (height && aspect_ratio))
        srcset = build_dpr_srcset(@options)
      else
        srcset = build_srcset_pairs(options: options, params: @options)
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

      widths = options['widths'.to_sym] || []
      width_tolerance = options['width_tolerance'.to_sym] ||  DEFAULT_WIDTH_TOLERANCE
      min_srcset = options['min_width'.to_sym] || MIN_WIDTH
      max_srcset = options['max_width'.to_sym] || MAX_WIDTH

      if !widths.empty?
        validate_widths!(widths)
        srcset_widths = widths
      elsif width_tolerance != DEFAULT_WIDTH_TOLERANCE or min_srcset != MIN_WIDTH or max_srcset != MAX_WIDTH
        validate_range!(min_srcset, max_srcset)
        srcset_widths = TARGET_WIDTHS.call(width_tolerance, min_srcset, max_srcset)
      else
        srcset_widths = @target_widths
      end

      for width in srcset_widths do
        params['w'.to_sym] = width
        srcset += "#{to_url(params)} #{width}w,\n"
      end

      srcset[0..-3]
    end

    def build_dpr_srcset(params)
      srcset = ''
      target_ratios = [1,2,3,4,5]
      quality = params['q'.to_sym]

      for index in 0..target_ratios.length - 1 do
        ratio = target_ratios[index]

        params['dpr'.to_sym] = ratio 
        params['q'.to_sym] = quality || DPR_QUALITY[index]
        srcset += "#{to_url(params)} #{ratio}x,\n"
      end

      srcset[0..-3]
    end

    def validate_widths!(widths)
      unless widths.is_a? Array
        raise ArgumentError, "The widths argument must be passed a valid array of integers"
      else
        positive_integers = widths.all? {|i| i.is_a?(Integer) and i > 0}
        unless positive_integers
          raise ArgumentError, "A custom widths array must only contain positive integer values"  
        end
      end
    end

    def validate_range!(min_srcset, max_srcset)
      if min_srcset.is_a? Numeric and max_srcset.is_a? Numeric
        unless min_srcset > 0 and max_srcset > 0
          raise ArgumentError, "The min and max arguments must be passed positive Numeric values"
        end
      else
        raise ArgumentError, "The min and max arguments must be passed positive Numeric values"
      end
    end
  end
end
