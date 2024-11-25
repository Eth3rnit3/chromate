# frozen_string_literal: true

require 'webrick'
require 'chromate/c_logger'

module Support
  module Modes
    def browser_args
      case ENV.fetch('CHROMATE_MODE', nil)
      when 'docker-xvfb'
        { headless: false, xfvb: true, native_control: true, record: "spec/video-records/#{example_name}.mp4" }
      when 'bot-browser'
        require 'bot_browser'
        BotBrowser.install unless BotBrowser.installed?
        BotBrowser.load
        { headless: false, xfvb: false, native_control: false }
      when 'debug'
        { headless: false, xfvb: false, native_control: false }
      else
        { headless: true, xfvb: false, native_control: false }
      end
    end

    def example_name
      if defined?(RSpec.current_example)
        RSpec.current_example.full_description.downcase.gsub(/\s+/, '-').gsub(/[^a-z0-9-]/, '')
      else
        Time.now.to_i.to_s
      end
    end
  end
end

# docker run -it --rm -v $(pwd):/app --env CHROMATE_MODE=docker-xvfb chromate:latest bundle exec rspec
