require 'base64'
require 'cgi/util'
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
    end

    def to_url(opts = {})
      prev_options = @options.dup
      @options.merge!(opts)

      url = @prefix + path_and_params

      if @secure_url_token
        url += (has_query? ? '&' : '?') + "s=#{signature}"
      end

      @options = prev_options
      return url
    end

    def defaults
      @options = {}
      return self
    end

    def method_missing(method, *args, &block)
      key = method.to_s.gsub('=', '')
      if args.length == 0
        return @options[key]
      elsif args.first.nil? && @options.has_key?(key)
        @options.delete(key) and return self
      end

      @options[key] = args.join(',')
      return self
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

    private

    def signature
      Digest::MD5.hexdigest(@secure_url_token + path_and_params)
    end

    def path_and_params
      has_query? ? "#{@path}?#{query}" : @path
    end

    def query
      @options.map do |key, val|
        escaped_key = CGI.escape(key.to_s)

        if escaped_key.end_with? '64'
          base64_encoded_val = Base64.urlsafe_encode64(val.to_s).delete('=')
          "#{escaped_key}=#{base64_encoded_val}"
        else
          "#{escaped_key}=#{CGI.escape(val.to_s)}"
        end
      end.join('&')
    end

    def has_query?
      query.length > 0
    end
  end
end
