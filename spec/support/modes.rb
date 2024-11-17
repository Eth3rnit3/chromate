# frozen_string_literal: true

require 'webrick'
require 'chromate/c_logger'

module Support
  module Modes
    def browser_args
      case ENV.fetch('CHROMATE_MODE', nil)
      when 'docker-xvfb'
        example_name = RSpec.current_example.full_description.downcase.gsub(/\s+/, '-').gsub(/[^a-z0-9-]/, '')
        { headless: false, xfvb: true, native_control: true, record: "spec/video-records/#{example_name}.mp4" }
      else
        { headless: true, xfvb: false, native_control: false }
      end
    end
  end
end

# docker run -it --rm -v $(pwd):/app --env CHROMATE_MODE=docker-xvfb chromate:latest bundle exec rspec
