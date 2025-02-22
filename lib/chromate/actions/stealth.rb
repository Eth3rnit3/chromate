require 'user_agent_parser'

module Chromate
  module Actions
    module Stealth
      # @return [void]
      def patch
        @client.send_message('Network.enable')
        inject_stealth_script

        # TODO: Improve dynamic user agent overriding
        # It currently breaks fingerprint validation (pixcelscan.com)
        # override_user_agent(@user_agent)
      end

      # @return [void]
      def inject_stealth_script
        stealth_script = File.read(File.join(__dir__, '../files/stealth.js'))
        @client.send_message('Page.addScriptToEvaluateOnNewDocument', { source: stealth_script })
      end

      # @param user_agent [String]
      # @return [void]
      def override_user_agent(user_agent) # rubocop:disable Metrics/MethodLength
        u_agent     = UserAgentParser.parse(user_agent)
        platform    = Chromate::UserAgent.os
        version     = u_agent.version
        brands      = [
          { brand: u_agent.family || 'Not_A_Brand', version: version.major },
          { brand: u_agent.device.brand || 'Not_A_Brand', version: u_agent.os.version.to_s }
        ]

        custom_headers = {
          'User-Agent' => user_agent,
          'Accept-Language' => 'en-US,en;q=0.9',
          'Sec-CH-UA' => brands.map { |brand| "\"#{brand[:brand]}\";v=\"#{brand[:version]}\"" }.join(', '),
          'Sec-CH-UA-Platform' => "\"#{u_agent.device.family}\"",
          'Sec-CH-UA-Mobile' => '?0'
        }
        @client.send_message('Network.setExtraHTTPHeaders', headers: custom_headers)

        user_agent_override = {
          userAgent: user_agent,
          platform: platform,
          acceptLanguage: 'en-US,en;q=0.9',
          userAgentMetadata: {
            brands: brands,
            fullVersion: version.to_s,
            platform: platform,
            platformVersion: u_agent.os.version.to_s,
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
