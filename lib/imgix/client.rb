# frozen_string_literal: true

require "digest"
require "addressable/uri"
require "net/http"
require "uri"
require "json"

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

      endpoint = URI.parse("https://api.imgix.com/api/v1/purge")
      # Ensure the path has been prefixed with '/'.
      path = path.start_with?("/") ? path : "/#{path}"
      url = prefix + path

      req = create_request(endpoint, url)

      sock = Net::HTTP.new(endpoint.host, endpoint.port)
      sock.use_ssl = true
      sock.start { |http| http.request(req) }
    end

    def prefix
      "#{@use_https ? 'https' : 'http'}://#{@domain}"
    end

    private

    def create_request(endpoint, img_url)
      req = Net::HTTP::Post.new(endpoint.path)
      req["Content-Type"] = "application/json"
      req["Authorization"] = "Bearer #{@api_key}"
      req["User-Agent"] = "imgix #{@library}-#{@version}"
      req.body = json_data(img_url)

      req
    end

    def json_data(url)
      {
        data: {
          attributes: {
              url: url
          },
          type: "purges"
        }
      }.to_json
    end

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
