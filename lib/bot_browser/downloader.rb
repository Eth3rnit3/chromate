module BotBrowser
  class Downloader
    class << self
      def download(version = nil)
        version ||= versions.keys.first
        version       = version.to_sym
        platform      = :mac
        arch          = :arm64
        binary_path   = download_file(versions[version][platform][arch][:binary], "/tmp/botbrowser_#{version}_#{platform}_#{arch}.dmg")
        profile_path  = download_file(versions[version][platform][arch][:profile], "/tmp/botbrowser_#{version}_#{platform}_#{arch}.json")

        [binary_path, profile_path]
      end

      def download_file(url, path)
        Chromate::CLogger.log("Downloading #{url} to #{path}")
        `curl -L #{url} >> #{path}`

        path
      end

      def versions
        {
          v130: {
            mac: {
              arm64: {
                binary: 'https://github.com/MiddleSchoolStudent/BotBrowser/releases/download/v130/botbrowser_130.0.6723.92_mac_arm64.dmg',
                profile: 'https://raw.githubusercontent.com/MiddleSchoolStudent/BotBrowser/refs/heads/main/profiles/v130/chrome130-macarm.enc'
              }
            },
            linux: {
              x64: {
                binary: 'https://github.com/MiddleSchoolStudent/BotBrowser/releases/download/v130/botbrowser_130.0.6723.117_amd64.deb',
                # no specifi linux profile for moment
                profile: 'https://raw.githubusercontent.com/MiddleSchoolStudent/BotBrowser/refs/heads/main/profiles/v130/chrome130-macarm.enc'
              }
            },
            windows: {
              x64: {
                binary: 'https://github.com/MiddleSchoolStudent/BotBrowser/releases/download/v130/botbrowser_130.0.6723.117_win_x86_64.7z',
                # no specific windows profile for moment
                profile: 'https://raw.githubusercontent.com/MiddleSchoolStudent/BotBrowser/refs/heads/main/profiles/v130/chrome130-macarm.enc'
              }
            }
          }
        }
      end
    end
  end
end
