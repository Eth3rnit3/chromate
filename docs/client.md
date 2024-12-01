# Client

The `Chromate::Client` class is responsible for managing WebSocket connections to Chrome DevTools Protocol (CDP). It handles communication between the Chromate library and the Chrome browser, including message sending, receiving, and event handling.

### Initialization

```ruby
client = Chromate::Client.new(browser)
```

- **Parameters:**
  - `browser` (Chromate::Browser): The browser instance to connect to.

### Public Methods

#### `#start`

Establishes the WebSocket connection to Chrome DevTools Protocol and sets up event handlers.

- **Returns:**
  - `self`: Returns the client instance for method chaining.

- **Example:**
  ```ruby
  client.start
  ```

#### `#stop`

Closes the WebSocket connection.

- **Returns:**
  - `self`: Returns the client instance for method chaining.

- **Example:**
  ```ruby
  client.stop
  ```

#### `#send_message(method, params = {})`

Sends a message to Chrome DevTools Protocol and waits for the response.

- **Parameters:**
  - `method` (String): The CDP method to call.
  - `params` (Hash, optional): Parameters for the CDP method.

- **Returns:**
  - `Hash`: The response from Chrome DevTools Protocol.

- **Example:**
  ```ruby
  result = client.send_message('DOM.getDocument')
  ```

#### `#reconnect`

Reestablishes the WebSocket connection if it was lost.

- **Returns:**
  - `self`: Returns the client instance for method chaining.

- **Example:**
  ```ruby
  client.reconnect
  ```

#### `#on_message`

Subscribes to WebSocket messages. Allows different parts of the application to listen for CDP events.

- **Parameters:**
  - `&block` (Block): The block to execute when a message is received.

- **Example:**
  ```ruby
  client.on_message do |message|
    puts "Received message: #{message}"
  end
  ```

### Class Methods

#### `.listeners`

Returns the array of registered message listeners.

- **Returns:**
  - `Array<Proc>`: The array of listener blocks.

### Event Handling

The client automatically handles several WebSocket events:

- `:message`: Processes incoming CDP messages and notifies listeners
- `:open`: Logs successful connection
- `:error`: Logs WebSocket errors
- `:close`: Logs connection closure

### Error Handling

The client includes automatic reconnection logic when message sending fails:

- Attempts to reconnect to the WebSocket
- Retries the failed message
- Logs errors and debug information through `Chromate::CLogger`

### Example Usage

```ruby
browser = Chromate::Browser.new
client = Chromate::Client.new(browser)

client.start

# Send a CDP command
result = client.send_message('DOM.getDocument')

# Listen for specific events
client.on_message do |msg|
  puts msg if msg['method'] == 'DOM.documentUpdated'
end

# Clean up
client.stop
```
