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
      @target_widths = TARGET_WIDTHS.call
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

    def to_srcset(params = {})
      prev_options = @options.dup
      @options.merge!(params)

      width = @options['w'.to_sym]
      height = @options['h'.to_sym]
      aspect_ratio = @options['ar'.to_sym]

      if ((width) || (height && aspect_ratio))
        srcset = build_dpr_srcset(@options)
      else
        srcset = build_srcset_pairs(@options)
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

    def build_srcset_pairs(params)
      srcset = ''

      for width in @target_widths do
        params['w'.to_sym] = width
        srcset += "#{to_url(params)} #{width}w,\n"
      end

      srcset[0..-3]
    end

    def build_dpr_srcset(params)
      srcset = ''
      target_ratios = [1,2,3,4,5]

      for ratio in target_ratios do
        params['dpr'.to_sym] = ratio
        srcset += "#{to_url(params)} #{ratio}x,\n"
      end

      srcset[0..-3]
    end
  end
end
