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

    def self.arch
      case RUBY_PLATFORM
      when /x64-mingw32/
        'x64'
      when /x86_64-mingw32/
        'x86_64'
      else
        'x86'
      end
    end

    def self.agents
      @agents ||= JSON.parse(File.read(File.join(__dir__, 'files/agents.json')))
    end

    def self.linux_agent
      agents['linux'].sample
    end

    def self.mac_agent
      agents['mac'].sample
    end

    def self.windows_agent
      agents['windows'].sample
    end
  end
end
