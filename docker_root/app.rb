require 'bundler/setup'
require 'chromate'
require '/chromate/spec/support/server'

class TestInDocker
  include Support::Server

  def run
    start_servers
    browser = Chromate::Browser.new(headless: false, xfvb: true, record: true, native_control: false)
    browser.start

    url = server_urls['where_moved']
    browser.navigate_to(url)
    browser.refresh
    browser.hover_element('#red')
    browser.hover_element('#yellow')
    browser.hover_element('#green')
    browser.hover_element('#blue')

    browser.screenshot('hover_all.png')

    browser.stop
    stop_servers
  end
end

TestInDocker.new.run
