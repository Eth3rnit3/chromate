require 'bundler/setup'
require 'chromate'

browser = Chromate::Browser.new(headless: false, xfvb: true, record: true, native_control: false)
browser.start
browser.navigate_to('https://www.google.com')
sleep 5
browser.screenshot('google.png')
browser.stop
