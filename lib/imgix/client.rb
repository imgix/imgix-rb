# frozen_string_literal: true

require "digest"
require "addressable/uri"
require "net/http"
require "uri"

module Imgix
  class Client
    DEFAULTS = { use_https: true }.freeze

    def initialize(options = {})
      options = DEFAULTS.merge(options)
      @domain = options[:domain]

      validate_domain!

      @secure_url_token = options[:secure_url_token]
      @api_key = options[:api_key]
      @use_https = options[:use_https]
      @include_library_param = options.fetch(:include_library_param, true)
      @library = options.fetch(:library_param, "rb")
      @version = options.fetch(:library_version, Imgix::VERSION)
    end

    def path(path)
      p = Path.new(prefix, @secure_url_token, path)
      p.ixlib("#{@library}-#{@version}") if @include_library_param
      p
    end

    def purge(path)
      api_key_error = "A valid api key is required to send purge requests"
      raise api_key_error if @api_key.nil?

      url = prefix + path
      uri = URI.parse("https://api.imgix.com/v2/image/purger")

      user_agent = { "User-Agent" => "imgix #{@library}-#{@version}" }

      req = Net::HTTP::Post.new(uri.path, user_agent)
      req.basic_auth @api_key, ""
      req.set_form_data({ url: url })

      sock = Net::HTTP.new(uri.host, uri.port)
      sock.use_ssl = true
      res = sock.start { |http| http.request(req) }

      res
    end

    def prefix
      "#{@use_https ? 'https' : 'http'}://#{@domain}"
    end

    private

    def validate_domain!
      domain_error  = "The :domain option must be specified"
      raise ArgumentError, domain_error if @domain.nil?

      domain_error = "Domains must be passed in as fully-qualified"\
                     "domain names and should not include a protocol"\
                     'or any path element, i.e. "example.imgix.net"'\

      raise ArgumentError, domain_error if @domain.match(DOMAIN_REGEX).nil?
    end
  end
end
