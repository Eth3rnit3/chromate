# frozen_string_literal: true

module Chromate
  class UserAgent
    # @return [String]
    def self.call
      new.call
    end

    attr_reader :os

    def initialize
      @os = find_os
    end

    # @return [String]
    def call
      'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Safari/537.36'
    end

    private

    # @return [String<'Macintosh', 'Linux', 'Windows', 'Unknown'>]
    def find_os
      case RUBY_PLATFORM
      when /darwin/
        'Macintosh'
      when /linux/
        'Linux'
      when /mswin|msys|mingw|cygwin|bccwin|wince|emc/
        'Windows'
      else
        'Unknown'
      end
    end
  end
end
