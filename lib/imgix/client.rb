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
      host = options[:host]
      domain = options[:domain]

      if host
        warn host_deprecated
        @host = host
      elsif domain
        @host = domain
      else
        @host = host
      end

      validate_host!

      @secure_url_token = options[:secure_url_token]
      @api_key = options[:api_key]
      @use_https = options[:use_https]
      @include_library_param = options.fetch(:include_library_param, true)
      @library = options.fetch(:library_param, "rb")
      @version = options.fetch(:library_version, Imgix::VERSION)
    end

    def path(path)
      p = Path.new(new_prefix, @secure_url_token, path)
      p.ixlib("#{@library}-#{@version}") if @include_library_param
      p
    end

    def purge(path)
      api_key_deprecated = \
        "Warning: Your `api_key` will no longer work after upgrading to\n" \
        "imgix-rb version >= 4.0.0.\n"
      warn api_key_deprecated

      api_key_error = "A valid api key is required to send purge requests"
      raise api_key_error if @api_key.nil?

      url = new_prefix + path
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

    def prefix(_path)
      msg = "Warning: `Client::prefix' will take zero arguments " \
        "in the next major version.\n"
      warn msg
      new_prefix
    end

    def new_prefix
      "#{@use_https ? 'https' : 'http'}://#{@host}"
    end

    private

    def validate_host!
      host_error = "The :host option must be specified"
      raise ArgumentError, host_error if @host.nil?

      domain_error = "Domains must be passed in as fully-qualified"\
                     "domain names and should not include a protocol"\
                     'or any path element, i.e. "example.imgix.net"'\

      raise ArgumentError, domain_error if @host.match(DOMAIN_REGEX).nil?
    end
  end
end
