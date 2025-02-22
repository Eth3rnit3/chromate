require 'user_agent_parser'

module Chromate
  module Actions
    module Stealth
      # @return [void]
      def patch
        @client.send_message('Network.enable')
        inject_stealth_script

        override_user_agent(@user_agent)
      end

      # @return [void]
      def inject_stealth_script
        stealth_script = File.read(File.expand_path('../files/stealth.js', __dir__))
        @client.send_message('Page.addScriptToEvaluateOnNewDocument', { source: stealth_script })
      end

      # @param user_agent [String]
      # @return [void]
      def override_user_agent(user_agent) # rubocop:disable Metrics/MethodLength
        user_agent  = UserAgentParser.parse(user_agent)
        platform    = Chromate::UserAgent.os
        version     = user_agent.version
        brands      = [
          { brand: user_agent.family || 'Not_A_Brand', version: version.major },
          { brand: user_agent.device.brand || 'Not_A_Brand', version: user_agent.os.version.to_s }
        ]

        custom_headers = {
          'User-Agent' => agent,
          'Accept-Language' => 'en-US,en;q=0.9',
          'Sec-CH-UA' => brands.map { |brand| "\"#{brand[:brand]}\";v=\"#{brand[:version]}\"" }.join(', '),
          'Sec-CH-UA-Platform' => "\"#{user_agent.device.family}\"",
          'Sec-CH-UA-Mobile' => '?0'
        }
        @client.send_message('Network.setExtraHTTPHeaders', headers: custom_headers)

        user_agent_override = {
          userAgent: agent,
          platform: platform,
          acceptLanguage: 'en-US,en;q=0.9',
          userAgentMetadata: {
            brands: brands,
            fullVersion: version.to_s,
            platform: platform,
            platformVersion: user_agent.os.version.to_s,
            architecture: Chromate::UserAgent.arch,
            model: '',
            mobile: false
          }
        }
        @client.send_message('Network.setUserAgentOverride', user_agent_override)
      end
    end
  end
end
