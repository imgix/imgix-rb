# frozen_string_literal: true

module Imgix
  class Variant
    def initialize(options = {})
      @options = options
      # Escape the query string up front to avoid repeating the same work each request
      @query = Imgix.escape_query_string(options)
    end

    attr_reader :query

    def [](key)
      @options[key]
    end
  end
end
