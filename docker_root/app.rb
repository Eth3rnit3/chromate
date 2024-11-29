require 'bundler/setup'
require 'chromate'
require '/chromate/spec/support/server'

class TestInDocker
  include Support::Server

  attr_reader :browser

  def initialize
    start_servers

    @browser = Chromate::Browser.new(headless: false, xfvb: true, record: 'record.mp4', native_control: false)
    @browser.start

    trap('INT') { stop }
    trap('TERM') { stop }

    at_exit { stop }
  end

  def stop
    @browser.stop
    stop_servers
    # Convert the video to a gif
    pid = spawn('ffmpeg -i record.mp4 -vf "fps=10,scale=640:-1:flags=lanczos,palettegen" palette.png')
    Process.wait(pid)
    pid = spawn('ffmpeg -i record.mp4 -i palette.png -filter_complex "fps=10,scale=640:-1:flags=lanczos[x];[x][1:v]paletteuse" TestInDocker.gif')
    Process.wait(pid)
  end

  def run
    click_features
    move_features
    drag_and_drop_features
    fill_form_features
    shadow_dom_features
  end

  def click_features
    url = server_urls['where_clicked']
    browser.navigate_to(url)
    browser.click_element('#interactive-button')
    sleep 1
  end

  def move_features
    url = server_urls['where_moved']
    browser.navigate_to(url)
    browser.hover_element('#red')
    browser.hover_element('#yellow')
    browser.hover_element('#green')
    browser.hover_element('#blue')
    sleep 1
  end

  def drag_and_drop_features
    url = server_urls['drag_and_drop']
    browser.navigate_to(url)
    blue_square = browser.find_element('#draggable')
    green_square = browser.find_element('#dropzone')
    blue_square.drop_to(green_square)
    sleep 1
  end

  def fill_form_features
    url = server_urls['fill_form']
    browser.navigate_to(url)
    browser.find_element('#first-name').type('John')
    browser.find_element('#last-name').type('Doe')
    browser.select_option('#gender', 'female')
    browser.find_element('#option-2').click
    browser.find_element('#submit-button').click
    sleep 1
  end

  def shadow_dom_features
    url = server_urls['shadow_checkbox']
    browser.navigate_to(url)
    shadow_container = browser.find_element('#shadow-container')
    checkbox = shadow_container.find_shadow_child('#shadow-checkbox')
    checkbox.click
    sleep 1
  end
end

TestInDocker.new.run
