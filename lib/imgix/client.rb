# frozen_string_literal: true

require 'digest'
require 'addressable/uri'
require 'zlib'
require 'net/http'
require 'uri'

module Imgix
  class Client
    DEFAULTS = { use_https: true, shard_strategy: :crc }

    def initialize(options = {})
      options = DEFAULTS.merge(options)

      @hosts = Array(options[:host]) + Array(options[:hosts]) and validate_hosts!
      @secure_url_token = options[:secure_url_token]
      @api_key = options[:api_key]
      @use_https = options[:use_https]
      @shard_strategy = options[:shard_strategy] and validate_strategy!
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
      "#{@use_https ? 'https' : 'http'}://#{get_host(path)}"
    end

    def get_host(path)
      host = host_for_crc(path) if @shard_strategy == :crc
      host = host_for_cycle if @shard_strategy == :cycle
      host.gsub("http://","").gsub("https://","").chomp("/")
    end

    def host_for_crc(path)
      crc = Zlib.crc32(path)
      index = crc % @hosts.length - 1
      @hosts[index]
    end

    def host_for_cycle
      @hosts_cycle = @hosts.cycle unless @hosts_cycle
      @hosts_cycle.next
    end

    private

    def validate_strategy!
      unless STRATEGIES.include?(@shard_strategy)
        raise ArgumentError.new("#{@shard_strategy} is not supported")
      end
    end

    def validate_hosts!
      unless @hosts.length > 0
        raise ArgumentError, "The :host or :hosts option must be specified"
      end
      @hosts.each do |host|
        unless host.match(DOMAIN_REGEX) != nil
          raise ArgumentError, "Domains must be passed in as fully-qualified domain names and should not include a protocol or any path element, i.e. \"example.imgix.net\"."
        end
      end
    end

  end
end
