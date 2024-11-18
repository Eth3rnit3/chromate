# frozen_string_literal: true

module Chromate
  module Actions
    module Stealth
      # @return [void]
      def patch
        @client.send_message('Network.enable')

        # Définir les en-têtes HTTP personnalisés
        custom_headers = {
          'User-Agent' => UserAgent.call,
          'Accept-Language' => 'fr-FR,fr;q=0.9,en-US;q=0.8,en;q=0.7,und;q=0.6,es;q=0.5,pt;q=0.4',
          'Sec-CH-UA' => '"Google Chrome";v="131", "Chromium";v="131", "Not_A Brand";v="24"',
          'Sec-CH-UA-Platform' => '"' + UserAgent.os + '"', # rubocop:disable Style/StringConcatenation
          'Sec-CH-UA-Mobile' => '?0'
        }

        # Appliquer les en-têtes personnalisés
        @client.send_message('Network.setExtraHTTPHeaders', headers: custom_headers)

        # Obtenir les informations de haute entropie pour éviter la détection
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
            platformVersion: '5.10', # Exemple pour Linux, à adapter selon l'OS
            architecture: 'x86_64',
            model: '',
            mobile: false
          }
        }

        # Appliquer l'override du User-Agent et des données de haute entropie
        @client.send_message('Network.setUserAgentOverride', user_agent_override)
      end
    end
  end
end
