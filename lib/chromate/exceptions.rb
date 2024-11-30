# frozen_string_literal: true

module Chromate
  module Exceptions
    class ChromateError < StandardError; end
    class InvalidBrowserError < ChromateError; end
    class InvalidPlatformError < ChromateError; end
    class ConnectionTimeoutError < StandardError; end
    class DebugURLError < StandardError; end
  end
end
