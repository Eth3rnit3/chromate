# frozen_string_literal: true

module Support
  module CleanupHelper
    def reset_client_mocks
      RSpec::Mocks.space.proxy_for(Chromate::Client).reset if defined?(Chromate::Client)
    end
  end
end
