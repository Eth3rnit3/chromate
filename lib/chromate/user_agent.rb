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
      case os
      when 'Linux'
        linux_agent
      when 'Macintosh'
        mac_agent
      when 'Windows'
        windows_agent
      else
        raise 'Unknown OS'
      end
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

    def linux_agent
      'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36'
    end

    def mac_agent
      'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Safari/537.36'
    end

    def windows_agent
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Safari/537.36'
    end
  end
end
