# frozen_string_literal: true

module Chromate
  class UserAgent
    # @return [String]
    def self.call
      case os
      when 'Linux'
        linux_agent
      when 'Mac'
        mac_agent
      when 'Windows'
        windows_agent
      else
        raise 'Unknown OS'
      end
    end

    # @return [String<'Mac', 'Linux', 'Windows', 'Unknown'>]
    def self.os
      case RUBY_PLATFORM
      when /darwin/
        'Mac'
      when /linux/
        'Linux'
      when /mswin|msys|mingw|cygwin|bccwin|wince|emc/
        'Windows'
      else
        'Unknown'
      end
    end

    def self.os_version
      case os
      when 'Linux'
        '5.15'
      when 'Mac'
        '13.0'
      when 'Windows'
        '10.0'
      else
        raise 'Unknown OS'
      end
    end

    def self.linux_agent
      'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36'
    end

    def self.mac_agent
      'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36'
    end

    def self.windows_agent
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36'
    end
  end
end
