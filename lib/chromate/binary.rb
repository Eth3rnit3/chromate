# frozen_string_literal: true

require 'open3'

module Chromate
  class Binary
    def self.run(path, args)
      command = [path] + args
      stdout, stderr, status = Open3.capture3(*command)
      raise stderr unless status.success?

      stdout
    end

    attr_reader :pid

    # @param [String] path
    # @param [Array<String>] args
    def initialize(path, args)
      @path = path
      @args = args || []
      @pid  = nil
    end

    # @return [self]
    def start
      command = [@path] + @args
      _stdin, _stdout, _stderr, wait_thr = Open3.popen3(*command)
      CLogger.log("Started process with pid #{wait_thr.pid}", level: :debug)
      Process.detach(wait_thr.pid)
      CLogger.log("Process detached with pid #{wait_thr.pid}", level: :debug)
      @pid = wait_thr.pid

      self
    end

    # @return [Boolean]
    def started?
      !@pid.nil?
    end

    # @return [self]
    def stop
      stop_process
    end

    # @return [Boolean]
    def stopped?
      @pid.nil?
    end

    private

    def stop_process(timeout: 5)
      return unless pid

      # Send SIGINT to the process to stop it gracefully
      Process.kill('INT', pid)
      begin
        Timeout.timeout(timeout) do
          Process.wait(pid)
        end
      rescue Timeout::Error
        # If the process does not stop gracefully, send SIGKILL
        CLogger.log("Process #{pid} did not stop gracefully. Sending SIGKILL...", level: :debug)
        Process.kill('KILL', pid)
        Process.wait(pid)
      end
    rescue Errno::ESRCH
      # The process has already stopped
    ensure
      @pid = nil
    end
  end
end
