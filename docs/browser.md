# Browser

The `Chromate::Browser` class is the main interface for interacting with the Chrome browser using the Chromate gem. It provides methods for navigating, interacting with elements, taking screenshots, and more.

## Initialization

To create a new instance of the `Browser` class, you can pass in various options:

```ruby
browser = Chromate::Browser.new(
  headless: true,
  native_control: true,
  user_data_dir: '/path/to/user/data',
  record: false
)
```

### Options

- `headless`: Run Chrome in headless mode (default: true).
- `native_control`: Use native mouse control (default: false).
- `user_data_dir`: Directory to store user data (default: a temporary directory).
- `record`: Record the browser session (default: false).
- `xfvb`: Use xvfb for headless mode (default: false).

## Methods

### 

start



Starts the Chrome browser with the specified options.

```ruby
browser.start
```

### 

stop



Stops the Chrome browser and any associated processes.

```ruby
browser.stop
```

### `navigate_to(url)`

Navigates to the specified URL and waits for the page to load.

```ruby
browser.navigate_to('http://example.com')
```

### `find_element(selector)`

Finds an element on the page using the specified CSS selector.

```ruby
element = browser.find_element('#some-element')
```

### `click_element(selector)`

Clicks on an element specified by the CSS selector.

```ruby
browser.click_element('#some-element')
```

### `hover_element(selector)`

Hovers over an element specified by the CSS selector.

```ruby
browser.hover_element('#some-element')
```

### `type_text(selector, text)`

Types text into an element specified by the CSS selector.

```ruby
browser.type_text('#input-field', 'Hello, world!')
```

### `screenshot_to_file(file_path, options = {})`

Takes a screenshot of the current page and saves it to the specified file path.

```ruby
browser.screenshot_to_file('screenshot.png')
```

### 

native_control?



Returns whether native control is enabled.

```ruby
puts browser.native_control? # => true or false
```

## Example Usage

```ruby
require 'chromate'

browser = Chromate::Browser.new(headless: true, native_control: true)
browser.start

browser.navigate_to('http://example.com')
browser.find_element('#some-element').click
browser.screenshot_to_file('screenshot.png')

browser.stop
```

## Private Methods

### 

start_video_recording



Starts recording the browser session using `ffmpeg`.

### 

build_args



Builds the arguments for starting the Chrome process.

### 

stop_and_exit



Stops the browser and exits the process.

### 

config



Returns the Chromate configuration.

## Conclusion

The `Chromate::Browser` class provides a powerful interface for automating interactions with the Chrome browser. With support for headless mode, native mouse control, and more, it is a versatile tool for creating undetectable bots with human-like behavior.