# Radio Element

The `Chromate::Elements::Radio` class represents a radio button input element in the browser. It extends the base `Element` class with specific functionality for radio buttons.

### Initialization

```ruby
radio = Chromate::Elements::Radio.new(selector, client, **options)
```

- **Parameters:**
  - `selector` (String): The CSS selector used to locate the radio button.
  - `client` (Chromate::Client): An instance of the CDP client.
  - `options` (Hash): Additional options passed to the Element constructor.

### Public Methods

#### `#checked?`

Returns whether the radio button is currently checked.

- **Returns:**
  - `Boolean`: `true` if the radio button is checked, `false` otherwise.

- **Example:**
  ```ruby
  if radio.checked?
    puts "Radio button is checked"
  end
  ```

#### `#check`

Checks the radio button if it's not already checked.

- **Returns:**
  - `self`: Returns the radio element for method chaining.

- **Example:**
  ```ruby
  radio.check
  ```

#### `#uncheck`

Unchecks the radio button if it's currently checked.

- **Returns:**
  - `self`: Returns the radio element for method chaining.

- **Example:**
  ```ruby
  radio.uncheck
  ```
