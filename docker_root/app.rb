require 'bundler/setup'
require 'chromate'
require '/chromate/spec/support/server'

class TestInDocker
  include Support::Server

  def run
    start_servers
    browser = Chromate::Browser.new(headless: false, xfvb: true, record: true, native_control: false)
    browser.start
    browser.screenshot('dom_actions_1.png')
    browser.navigate_to(server_urls['dom_actions'])
    browser.screenshot('dom_actions_2.png')
    browser.refresh
    browser.screenshot('dom_actions_3.png')
    sleep 5
    browser.screenshot('dom_actions_4.png')
    browser.stop
    stop_servers
  end
end

TestInDocker.new.run
