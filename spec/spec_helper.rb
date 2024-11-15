# frozen_string_literal: true

require 'chromate'

Dir[File.join(File.dirname(__FILE__), 'support/**/*.rb')].each { |file| require file }

RSpec.configure do |config|
  include Support::Server
  config.example_status_persistence_file_path = '.rspec_status'
  config.disable_monkey_patching!

  config.include Support::Server

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before(:suite) do |example|
    Chromate::CLogger.log('Starting test servers')
    start_servers
  end

  config.after(:suite) do |example|
    Chromate::CLogger.log('Stopping test servers')
    stop_servers
  end
end
