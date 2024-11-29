# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Shadow dom' do
  let(:browser) { Chromate::Browser.new(browser_args) }

  it 'fills the form' do
    browser.start
    url = server_urls['shadow_checkbox']
    browser.navigate_to(url)
    shadow_container = browser.find_element('#shadow-container')
    expect(shadow_container).to be_shadow_root
    checkbox = shadow_container.find_shadow_child('#shadow-checkbox')
    expect(checkbox).to be_a(Chromate::Element)
    checkbox.click

    browser.screenshot('spec/apps/shadow_checkbox/click.png')

    browser.stop
    expect(File.exist?('spec/apps/shadow_checkbox/click.png')).to be_truthy
  end

  it 'logs into the secure area' do
    browser.start
    url = server_urls['complex_login']
    browser.navigate_to(url)
    # Find and click the secure login container
    secure_login = browser.find_element('secure-login')
    locked_overlay = secure_login.find_shadow_child('#locked-overlay')
    locked_overlay.click

    # Handle the security challenge
    challenge_code = secure_login.find_shadow_child('#challenge-code').text
    challenge_input = secure_login.find_shadow_child('#challenge-input')
    challenge_input.type(challenge_code)
    verify_button = secure_login.find_shadow_child('#verify-challenge')
    verify_button.click

    # Fill in the login form
    username_input = secure_login.find_shadow_child('#username')
    password_input = secure_login.find_shadow_child('#password')
    username_input.type('admin')
    password_input.type('password')

    # Submit the login form
    login_form = secure_login.find_shadow_child('#login-form')
    login_form.find_element('button').click
    secure_zone = secure_login.find_shadow_child('#secure-zone')
    expect(secure_zone.text).to include('Accès autorisé')

    # Take a screenshot of the secure zone
    browser.screenshot('spec/apps/complex_login/secure_zone.png')

    browser.stop
    expect(File.exist?('spec/apps/complex_login/secure_zone.png')).to be true
  end
end
