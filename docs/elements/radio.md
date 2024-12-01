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

#### `#selected?`

Returns whether the radio button is currently selected.

- **Returns:**
  - `Boolean`: `true` if the radio button is selected, `false` otherwise.

- **Example:**
  ```ruby
  if radio.selected?
    puts "Radio button is selected"
  end
  ```

#### `#select`

Selects the radio button if it's not already selected.

- **Returns:**
  - `self`: Returns the radio element for method chaining.

- **Example:**
  ```ruby
  radio.select
  ```

#### `#unselect`

Unselects the radio button if it's currently selected.

- **Returns:**
  - `self`: Returns the radio element for method chaining.

- **Example:**
  ```ruby
  radio.unselect
  ```
