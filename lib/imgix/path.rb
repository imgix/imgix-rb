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

    def initialize(prefix, token, path = '/')
      @prefix = prefix
      @token = token
      @path = path
      @options = {}

      @path = "/#{@path}" if @path[0] != '/'
    end

    def to_url(opts={})
      prev_options = @options.dup
      @options.merge!(opts)
      
      url = @prefix + path_and_params
      url += (@options.length > 0 ? '&' : '') + "s=#{signature}"

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
      Digest::MD5.hexdigest(@token + @path + '?' + query)
    end

    def path_and_params
      "#{@path}?#{query}"
    end

    def query
      @options.map { |k, v| "#{k.to_s}=#{v}" }.join('&')
    end
  end
end