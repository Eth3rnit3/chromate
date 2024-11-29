# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Form' do
  let(:browser) { Chromate::Browser.new(browser_args) }

  it 'fills a full profile form' do
    browser.start
    url = server_urls['fill_form']
    browser.navigate_to(url)

    # Personnal informations
    browser.find_element('#first-name').type('John')
    browser.find_element('#last-name').type('Doe')
    browser.find_element('#birthdate').type('15/05/1990')
    # browser.select_option('#gender', 'other')
    select_tag = browser.find_element('#gender')
    select_tag.select_option('other')
    expect(select_tag.selected_value).to eq('other')
    expect(select_tag.selected_text).to eq('Autre')

    # Contact
    browser.find_element('#email').type('john.doe@example.com')
    browser.find_element('#phone').type('+555123456789')

    # Preferences
    # Interests
    browser.find_element('input[value="sport"]').click
    browser.find_element('input[value="tech"]').click

    # Biography
    browser.find_element('#bio').type('I am a passionate developer interested in new technologies and sports.')

    # Submit form
    browser.find_element('button[type="submit"]').click
    message = browser.find_element('#confirmation-message')
    expect(message.text).to include('Profil créé avec succès')

    # Capture screenshot
    browser.screenshot('spec/apps/fill_form/profile_form.png')

    browser.stop
    expect(File.exist?('spec/apps/fill_form/profile_form.png')).to be true
  end
end
