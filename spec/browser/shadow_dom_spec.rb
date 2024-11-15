# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Shadow dom' do
  let(:browser) { Chromate::Browser.new(headless: true) }

  it 'fills the form' do
    browser.start
    url = server_urls['shadow_checkbox']
    browser.navigate_to(url)
    shadow_container = browser.find_element('#shadow-container')
    expect(shadow_container).to be_shadow_root
    checkbox = shadow_container.find_shadow_child('#shadow-checkbox')
    expect(checkbox).to be_a(Chromate::Element)
    checkbox.click

    browser.screenshot_to_file('spec/apps/shadow_checkbox/click.png')

    browser.stop
    expect(File.exist?('spec/apps/shadow_checkbox/click.png')).to be_truthy
  end
end
