require 'digest'
require 'addressable/uri'
require 'zlib'

module Imgix
  class Client
    DEFAULTS = { secure: false, shard_strategy: :crc }

    def initialize(options = {})
      options = DEFAULTS.merge(options)

      @hosts = Array(options[:host]) + Array(options[:hosts]) and validate_hosts!
      @token = options[:token]
      @secure = options[:secure]
      @shard_strategy = options[:shard_strategy] and validate_strategy!
    end

    def path(path)
      Path.new(prefix(path), @token, path)
    end

    def prefix(path)
      "#{@secure ? 'https' : 'http'}://#{get_host(path)}"
    end

    def sign_path(path)
      self.path(path).sign
    end

    def get_host(path)
      host = host_for_crc(path) if @shard_strategy == :crc
      host = host_for_cycle if @shard_strategy == :cycle
      host.gsub("http://","").gsub("https://","")
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
    end

  end
end
