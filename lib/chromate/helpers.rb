# frozen_string_literal: true

require 'rbconfig'

module Chromate
  module Helpers
    # @return [Boolean]
    def linux?
      RbConfig::CONFIG['host_os'] =~ /linux|bsd/i
    end

    # @return [Boolean]
    def mac?
      RbConfig::CONFIG['host_os'] =~ /darwin/i
    end

    # @return [Boolean]
    def windows?
      RbConfig::CONFIG['host_os'] =~ /mswin|mingw|cygwin/i
    end

    # @return [Integer]
    def find_available_port
      server = TCPServer.new('127.0.0.1', 0)
      port = server.addr[1]
      server.close
      port
    end
  end
end
