# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

require "rubocop/rake_task"

RuboCop::RakeTask.new

task default: %i[spec rubocop]

require_relative "lib/chromate"

namespace :chromate do
  namespace :test do
    task :open do
      browser = Chromate::Browser.new(headless: false)
      browser.start
      browser.navigate_to("https://2captcha.com/fr/demo/recaptcha-v2")
      sleep 2
      element = browser.find_element("#root")
      binding.irb
      browser.stop
    end

    task :pixelscan do
      browser = Chromate::Browser.new
      browser.start
      browser.navigate_to("https://pixelscan.net")
      sleep 10
      browser.screenshot("results/pixelscan.png")
      browser.stop
    end

    task :brotector do
      require "chromate/native/mouse_controller"
      browser = Chromate::Browser.new
      browser.start
      browser.navigate_to("https://kaliiiiiiiiii.github.io/brotector?crash=false")
      sleep 2
      # browser.click_element("#clickHere")
      mouse = Chromate::Native::MouseController.new(browser.client)
      mouse.click(100, 100)
      browser.screenshot("results/brotector.png")
      browser.stop
    end

    task :bot do
      browser = Chromate::Browser.new
      browser.start
      browser.navigate_to("https://bot.sannysoft.com")
      sleep 2
      browser.screenshot("results/bot.png")
      browser.stop
    end

    task :cloudflare do
      Chromate.configure do |config|
        config.headless = false
      end
      browser = Chromate::Browser.new
      browser.start
      browser.navigate_to("https://2captcha.com/fr/demo/cloudflare-turnstile-challenge")
      sleep 10
      browser.screenshot("results/cloudflare.png")
      browser.stop
    end
  end
end