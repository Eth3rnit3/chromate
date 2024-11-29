# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Mouse' do
  let(:browser) { Chromate::Browser.new(browser_args) }

  it 'fills the form' do
    browser.start
    url = server_urls['fill_form']
    browser.navigate_to(url)
    browser.find_element('#first-name').type('John')
    browser.find_element('#last-name').type('Doe')
    browser.select_option('#gender', 'female')
    browser.find_element('#option-2').click
    browser.find_element('#submit-button').click
    browser.screenshot('spec/apps/fill_form/form.png')

    browser.stop
    expect(File.exist?('spec/apps/fill_form/form.png')).to be true
  end
end
