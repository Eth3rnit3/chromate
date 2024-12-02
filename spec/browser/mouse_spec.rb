# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Mouse' do
  let(:browser) { Chromate::Browser.new(browser_args) }

  it 'clicks the button' do
    browser.start
    url = server_urls['where_clicked']
    browser.navigate_to(url)
    browser.find_element('#interactive-button').click
    browser.screenshot('spec/apps/where_clicked/click.png')

    browser.stop
    expect(File.exist?('spec/apps/where_clicked/click.png')).to be true
  end

  it 'moves the mouse to the red button' do
    browser.start
    url = server_urls['where_moved']
    browser.navigate_to(url)
    browser.find_element('#red').hover
    browser.screenshot('spec/apps/where_moved/hover_element_red.png')

    browser.stop
    expect(File.exist?('spec/apps/where_moved/hover_element_red.png')).to be true
  end

  it 'moves the mouse to the blue button' do
    browser.start
    url = server_urls['where_moved']
    browser.navigate_to(url)
    browser.find_element('#blue').hover
    browser.screenshot('spec/apps/where_moved/hover_element_blue.png')

    browser.stop
    expect(File.exist?('spec/apps/where_moved/hover_element_blue.png')).to be true
  end

  it 'moves the mouse to the green button' do
    browser.start
    url = server_urls['where_moved']
    browser.navigate_to(url)
    browser.find_element('#green').hover
    browser.screenshot('spec/apps/where_moved/hover_element_green.png')

    browser.stop
    expect(File.exist?('spec/apps/where_moved/hover_element_green.png')).to be true
  end

  it 'moves the mouse to the yellow button' do
    browser.start
    url = server_urls['where_moved']
    browser.navigate_to(url)
    browser.find_element('#yellow').hover
    browser.screenshot('spec/apps/where_moved/hover_element_yellow.png')

    browser.stop
    expect(File.exist?('spec/apps/where_moved/hover_element_yellow.png')).to be true
  end

  it 'moves the mouse to all buttons' do
    browser.start
    url = server_urls['where_moved']
    browser.navigate_to(url)
    browser.find_element('#red').hover
    browser.find_element('#yellow').hover
    browser.find_element('#green').hover
    browser.find_element('#blue').hover
    browser.screenshot('spec/apps/where_moved/hover_element_all.png')

    browser.stop
    expect(File.exist?('spec/apps/where_moved/hover_element_all.png')).to be true
  end

  it 'drag and drop the blue square to the green square' do
    browser.start
    url = server_urls['drag_and_drop']
    browser.navigate_to(url)
    blue_square = browser.find_element('#draggable')
    green_square = browser.find_element('#dropzone')

    expect(green_square.text).to eq('Drop Here')

    blue_square.drop_to(green_square)

    expect(green_square.text).to eq('Dropped!')

    browser.screenshot('spec/apps/drag_and_drop/droped.png')

    browser.stop
    expect(File.exist?('spec/apps/drag_and_drop/droped.png')).to be true
  end
end
