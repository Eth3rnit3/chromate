# frozen_string_literal: true

require 'logger'

module Chromate
  class CLogger < Logger
    def initialize(logdev, shift_age: 0, shift_size: 1_048_576)
      super(logdev, shift_age, shift_size)
      self.formatter = proc do |severity, datetime, _progname, msg|
        "[Chromate] #{datetime.strftime("%Y-%m-%d %H:%M:%S")} #{severity}: #{msg}\n"
      end
    end

    def self.logger
      @logger ||= new($stdout)
    end

    def self.log(message, level: :info)
      logger.send(level, message)
    end
  end
end
