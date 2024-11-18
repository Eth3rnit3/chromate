# frozen_string_literal: true

module Chromate
  module Actions
    module Stealth
      # @return [void]
      def patch # rubocop:disable Metrics/MethodLength
        @client.send_message('Network.enable')

        # Define custom headers
        custom_headers = {
          'User-Agent' => UserAgent.call,
          'Accept-Language' => 'fr-FR,fr;q=0.9,en-US;q=0.8,en;q=0.7,und;q=0.6,es;q=0.5,pt;q=0.4',
          'Sec-CH-UA' => '"Google Chrome";v="131", "Chromium";v="131", "Not_A Brand";v="24"',
          'Sec-CH-UA-Platform' => '"' + UserAgent.os + '"', # rubocop:disable Style/StringConcatenation
          'Sec-CH-UA-Mobile' => '?0'
        }

        # Apply custom headers
        @client.send_message('Network.setExtraHTTPHeaders', headers: custom_headers)

        # Override User-Agent and high-entropy data to avoid fingerprinting
        user_agent_override = {
          userAgent: UserAgent.call,
          platform: UserAgent.os,
          acceptLanguage: 'fr-FR,fr;q=0.9,en-US;q=0.8',
          userAgentMetadata: {
            brands: [
              { brand: 'Google Chrome', version: '131' },
              { brand: 'Chromium', version: '131' },
              { brand: 'Not_A Brand', version: '24' }
            ],
            fullVersion: '131.0.0.0',
            platform: UserAgent.os,
            platformVersion: UserAgent.os_version,
            architecture: 'x86_64',
            model: '',
            mobile: false
          }
        }

        # Apply User-Agent override and high-entropy data
        @client.send_message('Network.setUserAgentOverride', user_agent_override)
      end
    end
  end
end
