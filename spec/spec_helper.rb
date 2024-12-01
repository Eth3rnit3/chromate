# frozen_string_literal: true

require 'chromate'

Dir[File.join(File.dirname(__FILE__), 'support/**/*.rb')].each { |file| require file }

RSpec.configure do |config|
  include Support::Server
  include Support::ClientHelper
  include Support::CleanupHelper

  config.example_status_persistence_file_path = '.rspec_status'
  config.disable_monkey_patching!

  config.include Support::Server
  config.include Support::Modes

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before(:suite) do |_example|
    Chromate::CLogger.log('Starting test servers')
    start_servers
  end

  config.after(:suite) do |_example|
    Chromate::CLogger.log('Stopping test servers')
    stop_servers
  end

  config.after(:each) do
    reset_client_mocks
  end
end
