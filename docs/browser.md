## `Chromate::Browser` Class

The `Chromate::Browser` class is responsible for controlling a browser instance using the Chrome DevTools Protocol (CDP). It provides methods for navigation, screenshots, and DOM interactions, as well as handling browser lifecycle (start and stop).

### Initialization

```ruby
browser = Chromate::Browser.new(options = {})
```

- **Parameters:**
  - `options` (Hash, optional): Configuration options for the browser instance.
    - `:chrome_path` (String): Path to the Chrome executable.
    - `:user_data_dir` (String): Directory for storing user data (default: a temporary directory).
    - `:headless` (Boolean): Run the browser in headless mode.
    - `:xfvb` (Boolean): Use Xvfb for headless mode on Linux.
    - `:native_control` (Boolean): Enable native control for enhanced undetection.
    - `:record` (Boolean): Enable video recording of the browser session.

### Public Methods

#### `#start`

Starts the browser process and initializes the CDP client.

- **Example:**
  ```ruby
  browser.start
  ```

#### `#stop`

Stops the browser process, including any associated Xvfb or video recording processes.

- **Example:**
  ```ruby
  browser.stop
  ```

#### `#native_control?`

Checks if native control is enabled for the browser instance.

- **Returns:**
  - `Boolean`: `true` if native control is enabled, `false` otherwise.

- **Example:**
  ```ruby
  puts "Native control enabled" if browser.native_control?
  ```

### Navigation Methods (from `Actions::Navigate`)

#### `#navigate_to(url)`

Navigates the browser to the specified URL.

- **Parameters:**
  - `url` (String): The URL to navigate to.

- **Example:**
  ```ruby
  browser.navigate_to('https://example.com')
  ```

#### `#wait_for_page_load`

Waits until the page has fully loaded, including the `DOMContentLoaded` event, `load` event, and `frameStoppedLoading` event.

- **Example:**
  ```ruby
  browser.wait_for_page_load
  ```

#### `#refresh`

Reloads the current page.

- **Example:**
  ```ruby
  browser.refresh
  ```

#### `#go_back`

Navigates back to the previous page in the browser history.

- **Example:**
  ```ruby
  browser.go_back
  ```

### Screenshot Methods (from `Actions::Screenshot`)

#### `#screenshot(file_path, options = {})`

Takes a screenshot of the current page and saves it to the specified file.

- **Parameters:**
  - `file_path` (String, optional): The file path to save the screenshot.
  - `options` (Hash, optional): Additional options for the screenshot.
  - - `full_page` (Boolean, optional): Take a full page screenshot

It will call `#xvfb_screenshot` private method if `xvfb` mode is `true`

- **Example:**
  ```ruby
  browser.screenshot('screenshot.png')
  ```

### DOM Methods (from `Actions::Dom`)

#### `#find_element(selector)`

Finds a single element on the page using the specified CSS selector.

- **Parameters:**
  - `selector` (String): The CSS selector to locate the element.

- **Returns:**
  - `Chromate::Element`: The found element.

- **Example:**
  ```ruby
  element = browser.find_element('#my-element')
  puts element.text
  ```

#### `#click_element(selector)`

Finds an element by selector and clicks it.

- **Parameters:**
  - `selector` (String): The CSS selector of the element to click.

- **Example:**
  ```ruby
  browser.click_element('#submit-button')
  ```

#### `#hover_element(selector)`

Finds an element by selector and hovers over it.

- **Parameters:**
  - `selector` (String): The CSS selector of the element to hover.

- **Example:**
  ```ruby
  browser.hover_element('#hover-target')
  ```

#### `#type_text(selector, text)`

Finds an element by selector and types the specified text into it.

- **Parameters:**
  - `selector` (String): The CSS selector of the element.
  - `text` (String): The text to type into the element.

- **Example:**
  ```ruby
  browser.type_text('#input-field', 'Hello, Chromate!')
  ```

#### `#select_option(selector, option)`

Selects an option from a dropdown element.

- **Parameters:**
  - `selector` (String): The CSS selector of the dropdown element.
  - `option` (String): The value of the option to select.

- **Example:**
  ```ruby
  browser.select_option('#dropdown', 'option2')
  ```

#### `#evaluate_script(script)`

Executes the specified JavaScript expression on the page.

- **Parameters:**
  - `script` (String): The JavaScript code to evaluate.

- **Returns:**
  - The result of the JavaScript evaluation.

- **Example:**
  ```ruby
  result = browser.evaluate_script('document.title')
  puts "Page title: #{result}"
  ```

### Exception Handling

- The browser handles `INT` and `TERM` signals gracefully by stopping the browser process and exiting safely.
- The `stop_and_exit` method is used to ensure proper shutdown.

### Example Usage

```ruby
require 'chromate'

options = {
  chrome_path: '/usr/bin/google-chrome',
  headless: true,
  native_control: true,
  record: true
}

browser = Chromate::Browser.new(options)

browser.start
browser.navigate_to('https://example.com')
browser.screenshot('example.png')
element = browser.find_element('#main-header')
puts element.text
browser.stop
```