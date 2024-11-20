require 'yaml'
require 'chromate/c_logger'
require 'bot_browser/installer'

module BotBrowser
  class << self
    def install(version = nil)
      Installer.install(version)
    end

    def installed?
      File.exist?("#{Dir.home}/.botbrowser/config.yml")
    end

    def load
      yaml = YAML.load_file("#{Dir.home}/.botbrowser/config.yml")

      Chromate.configure do |config|
        ENV['CHROME_BIN'] = yaml['bot_browser_path']
        config.args = [
          "--bot-profile=#{yaml["profile"]}",
          '--no-sandbox'
        ]
        config.startup_patch = false
      end

      Chromate::CLogger.log('BotBrowser loaded', level: :debug)
    end
  end
end

# Usage
# require 'bot_browser'

# BotBrowser.install
# BotBrowser.load
# browser = Chromate::Browser.new
