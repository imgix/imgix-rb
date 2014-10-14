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

      # Weird bug in imgix. If there are no params, you still have
      # to put & in front of the signature or else you will get
      # unauthorized.
      if signed?
        url += "&s=#{signature}"
      end

      @options = prev_options
      return url
    end
    alias_method :to_s, :to_url

    def sign
      @signed = true
      return self
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
      Digest::MD5.hexdigest(@token + path_and_params)
    end

    def path_and_params
      path = @path
      path += '?' if need_param_symbol?
      path += query if query?

      return path
    end

    def need_param_symbol?
      !@path.include?('?') && (query? || signed?)
    end

    def query?
      @options.any?
    end

    def signed?
      @signed
    end

    def query
      @options.map { |k, v| "#{k.to_s}=#{v}" }.join('&')
    end
  end
end
