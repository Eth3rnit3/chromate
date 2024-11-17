# frozen_string_literal: true

require_relative 'chromate/version'
require_relative 'chromate/browser'
require_relative 'chromate/configuration'

module Chromate
  class << self
    # @yield [Chromate::Configuration]
    def configure
      yield configuration
    end

    # @return [Chromate::Configuration]
    def configuration
      @configuration ||= Configuration.new
    end
  end
end
