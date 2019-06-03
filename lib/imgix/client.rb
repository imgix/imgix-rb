# frozen_string_literal: true

require 'digest'
require 'addressable/uri'
require 'net/http'
require 'uri'

module Imgix
  class Client
    DEFAULTS = { use_https: true }

    def initialize(options = {})
      options = DEFAULTS.merge(options)

      @host = options[:host]
      validate_host!
      @secure_url_token = options[:secure_url_token]
      @api_key = options[:api_key]
      @use_https = options[:use_https]
      @include_library_param = options.fetch(:include_library_param, true)
      @library = options.fetch(:library_param, "rb")
      @version = options.fetch(:library_version, Imgix::VERSION)
    end

    def path(path)
      p = Path.new(prefix(path), @secure_url_token, path)
      p.ixlib("#{@library}-#{@version}") if @include_library_param
      p
    end

    def purge(path)
      raise "Authentication token required" unless !!(@api_key)
      url = prefix(path)+path
      uri = URI.parse('https://api.imgix.com/v2/image/purger')
      req = Net::HTTP::Post.new(uri.path, {"User-Agent" => "imgix #{@library}-#{@version}"})
      req.basic_auth @api_key, ''
      req.set_form_data({'url' => url})
      sock = Net::HTTP.new(uri.host, uri.port)
      sock.use_ssl = true
      res = sock.start {|http| http.request(req) }
      res
    end

    def prefix(path)
      "#{@use_https ? 'https' : 'http'}://#{@host}"
    end

    private

    def validate_host!
      unless @host != nil
        raise ArgumentError, "The :host option must be specified"
      end
      if @host.match(DOMAIN_REGEX) == nil
        raise ArgumentError, "Domains must be passed in as fully-qualified domain names and should not include a protocol or any path element, i.e. \"example.imgix.net\"."
      end
    end
    
  end
end
