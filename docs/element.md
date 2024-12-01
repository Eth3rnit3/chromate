# Element

The `Chromate::Element` class represents a DOM element in a browser controlled via the Chrome DevTools Protocol (CDP). It provides methods to interact with the element, including manipulating its attributes, getting its text content, and simulating user actions.

### Initialization

```ruby
element = Chromate::Element.new(selector, client, node_id: nil, object_id: nil, root_id: nil)
```

- **Parameters:**
  - `selector` (String): The CSS selector used to locate the element.
  - `client` (Chromate::Client): An instance of the CDP client.
  - `node_id` (Integer, optional): The node ID of the element.
  - `object_id` (String, optional): The object ID of the element.
  - `root_id` (Integer, optional): The root node ID of the document.

### Public Methods

#### `#mouse`

Returns the mouse controller for interacting with the element.

- **Example:**
  ```ruby
  element.mouse.click
  ```

#### `#keyboard`

Returns the keyboard controller for interacting with the element.

- **Example:**
  ```ruby
  element.keyboard.type('Hello World')
  ```

#### `#inspect`

Returns a string representation of the element.

- **Example:**
  ```ruby
  puts element.inspect
  ```

#### `#text`

Retrieves the inner text of the element.

- **Example:**
  ```ruby
  text = element.text
  puts "Element text: #{text}"
  ```

#### `#html`

Retrieves the outer HTML of the element.

- **Example:**
  ```ruby
  html = element.html
  puts "Element HTML: #{html}"
  ```

#### `#attributes`

Returns a hash of the element's attributes.

- **Example:**
  ```ruby
  attributes = element.attributes
  puts "Element attributes: #{attributes}"
  ```

#### `#tag_name`

Gets the HTML tag name of the element in lowercase.

- **Returns:**
  - `String`: The HTML tag name.

- **Example:**
  ```ruby
  tag = element.tag_name
  puts "Tag name: #{tag}"
  ```

#### `#set_attribute(name, value)`

Sets an attribute on the element.

- **Parameters:**
  - `name` (String): The name of the attribute.
  - `value` (String): The value to set for the attribute.

- **Example:**
  ```ruby
  element.set_attribute('class', 'highlighted')
  ```

#### `#bounding_box`

Returns a hash with the dimensions of the element's bounding box.

- **Example:**
  ```ruby
  box = element.bounding_box
  puts "Bounding box: #{box}"
  ```

#### `#x`

Returns the x-coordinate of the element's position.

- **Example:**
  ```ruby
  x_position = element.x
  puts "X Position: #{x_position}"
  ```

#### `#y`

Returns the y-coordinate of the element's position.

- **Example:**
  ```ruby
  y_position = element.y
  puts "Y Position: #{y_position}"
  ```

#### `#width`

Returns the width of the element.

- **Example:**
  ```ruby
  width = element.width
  puts "Element width: #{width}"
  ```

#### `#height`

Returns the height of the element.

- **Example:**
  ```ruby
  height = element.height
  puts "Element height: #{height}"
  ```

#### `#focus`

Sets focus on the element.

- **Example:**
  ```ruby
  element.focus
  ```

#### `#click`

Simulates a click on the element.

- **Example:**
  ```ruby
  element.click
  ```

#### `#hover`

Simulates a hover action over the element.

- **Example:**
  ```ruby
  element.hover
  ```

#### `#type(text)`

Types the specified text into the element.

- **Parameters:**
  - `text` (String): The text to type.

- **Example:**
  ```ruby
  element.type('Hello, Chromate!')
  ```

#### `#press_enter`

Simulates pressing the Enter key and submits the form if the element is inside one.

- **Example:**
  ```ruby
  element.press_enter
  ```

#### `#drop_to(element)`

Drag current element and drop to target

- **Example:**
  ```ruby
  element.drop_to(target_element)
  ```

#### `#find_element(selector)`

Finds a single child element matching the given selector.

- **Parameters:**
  - `selector` (String): The CSS selector to find the element.

- **Returns:**
  - `Chromate::Element`: The found element.

- **Example:**
  ```ruby
  child_element = element.find_element('.child')
  puts child_element.text
  ```

#### `#find_elements(selector, max: 0)`

Finds all child elements matching the given selector.

- **Parameters:**
  - `selector` (String): The CSS selector to find elements.
  - `max` (Integer, optional): The maximum number of elements to find (0 for no limit).

- **Returns:**
  - `Array<Chromate::Element>`: An array of found elements.

- **Example:**
  ```ruby
  elements = element.find_elements('.item')
  elements.each { |el| puts el.text }
  ```

#### `#shadow_root_id`

Returns the shadow root ID of the element if it has one.

- **Example:**
  ```ruby
  shadow_id = element.shadow_root_id
  puts "Shadow root ID: #{shadow_id}"
  ```

#### `#shadow_root?`

Checks if the element has a shadow root.

- **Returns:**
  - `Boolean`: `true` if the element has a shadow root, otherwise `false`.

- **Example:**
  ```ruby
  if element.shadow_root?
    puts "Element has a shadow root."
  end
  ```

#### `#find_shadow_child(selector)`

Finds a single child element inside the shadow root using the given selector.

- **Parameters:**
  - `selector` (String): The CSS selector to find the shadow child element.

- **Returns:**
  - `Chromate::Element` or `nil`: The found element or `nil` if not found.

- **Example:**
  ```ruby
  shadow_child = element.find_shadow_child('.shadow-element')
  puts shadow_child.text if shadow_child
  ```

#### `#find_shadow_children(selector)`

Finds all child elements inside the shadow root using the given selector.

- **Parameters:**
  - `selector` (String): The CSS selector to find shadow child elements.

- **Returns:**
  - `Array<Chromate::Element>`: An array of found elements.

- **Example:**
  ```ruby
  shadow_elements = element.find_shadow_children('.shadow-item')
  shadow_elements.each { |el| puts el.text }
  ```

#### `#value`

Gets the value of the element.

- **Returns:**
  - `String`: The element's value.

- **Example:**
  ```ruby
  value = element.value
  puts "Element value: #{value}"
  ```

### Exceptions

- `NotFoundError`: Raised when an element cannot be found with the given selector.
- `InvalidSelectorError`: Raised when the selector cannot resolve to a valid element.

## Specialized Elements

Chromate provides specialized element classes for specific HTML elements that have unique behaviors and methods. When using `find_element`, Chromate automatically returns the appropriate specialized element based on the element type.

### Available Specialized Elements

- [Select Element](elements/select.md): For `<select>` elements
- [Option Element](elements/option.md): For `<option>` elements within select elements
- [Radio Element](elements/radio.md): For radio button inputs (`<input type="radio">`)
- [Checkbox Element](elements/checkbox.md): For checkbox inputs (`<input type="checkbox">`)

Each specialized element inherits from the base `Element` class and adds specific methods for interacting with that type of element. See the individual documentation files for details on the methods available for each element type.