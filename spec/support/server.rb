# frozen_string_literal: true

require 'webrick'
require 'chromate/c_logger'

module Support
  module Server
    def start_servers
      directories   = Dir['spec/apps/*'].select { |entry| File.directory?(entry) }
      ports         = (12_500..12_800).to_a
      @@servers     = [] # rubocop:disable Style/ClassVars
      @@server_urls = {} # rubocop:disable Style/ClassVars

      directories.each_with_index do |directory, index|
        port = ports[index]
        next unless port

        server = WEBrick::HTTPServer.new(
          Port: port,
          DocumentRoot: directory,
          Logger: WEBrick::Log.new(nil, WEBrick::Log::ERROR),
          AccessLog: []
        )

        thread = Thread.new { server.start }

        @@servers << { server: server, thread: thread }
        @@server_urls[File.basename(directory)] = "http://localhost:#{port}"
        Chromate::CLogger.log("Server started for #{directory} on port #{port}")
      end

      # Stop servers when the test suite is interrupted
      trap('INT') { properly_exit }
      # Stop servers when the test suite is stopped
      trap('TERM') { properly_exit }
      # Stop servers when the test suite is done
      at_exit { properly_exit }

      true
    end

    def servers
      @@servers
    end

    def server_urls
      @@server_urls
    end

    def properly_exit
      stop_servers
    rescue StandardError => e
      Chromate::CLogger.log("Error stopping servers: #{e.message}")
    ensure
      exit
    end

    def stop_servers(status = 0)
      @@servers.each do |entry|
        entry[:server].shutdown
        entry[:thread].join if entry[:thread].alive?
        Chromate::CLogger.log("Server stopped for port #{entry[:server].config[:Port]}")
      end

      exit(status)
    end
  end
end
