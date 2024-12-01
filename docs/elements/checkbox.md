# Checkbox Element

The `Chromate::Elements::Checkbox` class represents a checkbox input element in the browser. It extends the base `Element` class with specific functionality for checkboxes.

### Initialization

```ruby
checkbox = Chromate::Elements::Checkbox.new(selector, client, **options)
```

- **Parameters:**
  - `selector` (String): The CSS selector used to locate the checkbox.
  - `client` (Chromate::Client): An instance of the CDP client.
  - `options` (Hash): Additional options passed to the Element constructor.
    - `object_id` (String): Optional. The object ID of a pre-searched element.
    - `node_id` (Integer): Optional. The node ID of a pre-searched element.
    - `root_id` (Integer): Optional. The root ID of a pre-searched element.

### Public Methods

#### `#checked?`

Returns whether the checkbox is currently checked.

- **Returns:**
  - `Boolean`: `true` if the checkbox is checked, `false` otherwise.

- **Example:**
  ```ruby
  if checkbox.checked?
    puts "Checkbox is checked"
  end
  ```

#### `#check`

Checks the checkbox if it's not already checked.

- **Returns:**
  - `self`: Returns the checkbox element for method chaining.

- **Example:**
  ```ruby
  checkbox.check
  ```

#### `#uncheck`

Unchecks the checkbox if it's currently checked.

- **Returns:**
  - `self`: Returns the checkbox element for method chaining.

- **Example:**
  ```ruby
  checkbox.uncheck
  ```

#### `#toggle`

Toggles the checkbox state (checks if unchecked, unchecks if checked).

- **Returns:**
  - `self`: Returns the checkbox element for method chaining.

- **Example:**
  ```ruby
  checkbox.toggle
  ```
