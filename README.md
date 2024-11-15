# Chromate
[![eth3rnit3 - chromate](https://img.shields.io/static/v1?label=eth3rnit3&message=chromate&color=a8a9ad&logo=ruby&labelColor=9b111e)](https://github.com/eth3rnit3/chromate "Go to GitHub repo")
[![GitHub release](https://img.shields.io/github/release/eth3rnit3/chromate?include_prereleases=&sort=semver&color=a8a9ad)](https://github.com/eth3rnit3/chromate/releases/)
[![License](https://img.shields.io/badge/License-MIT-a8a9ad)](#license)
[![Ruby](https://github.com/Eth3rnit3/chromate/actions/workflows/main.yml/badge.svg)](https://github.com/Eth3rnit3/chromate/actions/workflows/main.yml)
[![issues - chromate](https://img.shields.io/github/issues/eth3rnit3/chromate)](https://github.com/eth3rnit3/chromate/issues)

![logo](logo.png)

Chromate is a custom driver for Chrome using the Chrome DevTools Protocol (CDP) to create undetectable bots with human-like behavior. The ultimate goal is to enable the creation of AI agents capable of navigating and performing actions on the web on behalf of the user. This gem is the first step towards achieving that goal.

## Installation

Add gem to your application's Gemfile:

```sh
bundle add chromate
```

Or install it yourself as:

```sh
gem install chromate
```

## Usage

[![view - Documentation](https://img.shields.io/badge/view-Documentation-blue?style=for-the-badge)](/docs/ "Go to project documentation")

### Basic Example

```ruby
require 'chromate'

browser = Chromate::Browser.new # default headless: true
browser.start

url = 'http://example.com'
browser.navigate_to(url)
browser.find_element('#some-element').click
browser.screenshot_to_file('screenshot.png')

browser.stop
```

### Configuration

You can configure Chromate using a block:

```ruby
Chromate.configure do |config|
  config.user_data_dir = '/path/to/user/data'
  config.headless = true
  config.native_control = true
  config.proxy = { host: 'proxy.example.com', port: 8080 }
end
```

## Principle of Operation

Chromate leverages the Chrome DevTools Protocol (CDP) to interact with the browser. It provides a custom driver that mimics human-like behavior to avoid detection by anti-bot systems. The gem includes native mouse controllers for macOS and Linux, which do not trigger JavaScript events, making interactions more human-like.

### Features

- **Headless Mode**: Run Chrome without a graphical user interface.
- **Native Mouse Control**: Use native mouse events for macOS and Linux.
- **Screenshot Capture**: Capture screenshots of the browser window.
- **Form Interaction**: Fill out and submit forms.
- **Shadow DOM Support**: Interact with elements inside Shadow DOM.
- **Element Interaction**: Click, hover, and type text into elements.
- **Navigation**: Navigate to URLs and wait for page load.
- **Docker xvfb Support**: Dockerfile provided with xvfb setup for easy usage.

### Limitations

- **Windows Support**: Native mouse control is not yet supported on Windows.
- **Headless Mode Complexity**: Requires xvfb for headless mode, adding complexity due to different proportions.
- **Anti-Bot Detection**: Current systems can detect keyboard and mouse interactions via CDP.

# Native controls and headless

Chromate provides native mouse control for macOS and Linux, which helps in creating more human-like interactions that are harder to detect by anti-bot systems. However, using native controls in headless mode requires additional setup, such as using xvfb (X Virtual Framebuffer) to simulate a display.

## Docker Setup

To simplify the setup process, Chromate includes a Dockerfile and an entrypoint script that handle the installation and configuration of necessary dependencies, including xvfb.

### Dockerfile

The Dockerfile sets up a minimal environment with all the necessary dependencies to run Chromate in headless mode with xvfb. It installs Chrome, xvfb, and other required libraries.

The [entrypoint](dockerfiles/docker-entrypoint.sh) script ensures that xvfb is running before starting the main process. It removes any existing lock files, starts xvfb and a window manager (fluxbox), and waits for xvfb to initialize.

### Example Docker Usage

Here is an example of how you can use Chromate inside a Docker container:

```sh
# Build the Docker image
docker build -f dockerfiles/Dockerfile -t chromate .

# Run the Docker container
docker run -v $(pwd):/app -it chromate

# Inside the container, run your Ruby script
ruby your_script.rb # or bundle exec rspec
```

This setup ensures that all necessary dependencies are installed and configured correctly, allowing you to focus on writing your automation scripts without worrying about the underlying environment.

## Contribution

Contributions are welcome! If you have suggestions for improvements or new features, please open an issue or submit a pull request on GitHub.

### How to Contribute

1. Fork the repository.
2. Create a new branch (`git checkout -b feature-branch`).
3. Make your changes.
4. Commit your changes (`git commit -am 'Add new feature'`).
5. Push to the branch (`git push origin feature-branch`).
6. Create a new Pull Request.

## License

Released under [MIT](/LICENSE.txt) by [@eth3rnit3](https://github.com/eth3rnit3).