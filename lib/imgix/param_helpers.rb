# frozen_string_literal: true

module Imgix
  module ParamHelpers
    def rect(position)
      @options[:rect] = position and return self if position.is_a?(String)

      @options[:rect] = [
        position[:x] || position[:left],
        position[:y] || position[:top],
        position[:width] || (position[:right] - position[:left]),
        position[:height] || (position[:bottom] - position[:top])
      ].join(',')

      return self
    end
  end
end
