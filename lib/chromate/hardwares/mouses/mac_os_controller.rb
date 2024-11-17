# frozen_string_literal: true

require 'ffi'
require 'chromate/helpers'
module Chromate
  module Hardwares
    module Mouses
      class MacOsController < MouseController
        class InvalidPlatformError < StandardError; end
        include Helpers
        extend FFI::Library

        ffi_lib '/System/Library/Frameworks/ApplicationServices.framework/ApplicationServices'

        class CGPoint < FFI::Struct
          layout :x, :float,
                 :y, :float
        end

        attach_function :CGEventCreateMouseEvent, [:pointer, :uint32, CGPoint.by_value, :uint32], :pointer
        attach_function :CGEventPost, %i[uint32 pointer], :void
        attach_function :CGEventSetType, %i[pointer uint32], :void
        attach_function :CFRelease, [:pointer], :void
        attach_function :CGMainDisplayID, [], :uint32
        attach_function :CGEventCreate, [:pointer], :pointer
        attach_function :CGEventGetLocation, [:pointer], CGPoint.by_value
        attach_function :CGDisplayPixelsHigh, [:uint32], :size_t

        class CGSize < FFI::Struct
          layout :width, :float,
                 :height, :float
        end

        LEFT_DOWN   = 1
        LEFT_UP     = 2
        RIGHT_DOWN  = 3
        RIGHT_UP    = 4
        MOUSE_MOVED = 5

        def initialize(element: nil, client: nil)
          raise InvalidPlatformError, 'MouseController is only supported on macOS' unless mac?

          super
          @main_display = CGMainDisplayID()
          @display_height = CGDisplayPixelsHigh(@main_display).to_f
          @scale_factor = determine_scale_factor
        end

        def hover
          point = convert_coordinates(target_x, target_y)
          create_and_post_event(MOUSE_MOVED, point)
          current_mouse_position
        end

        def click
          current_pos = current_mouse_position
          create_and_post_event(LEFT_DOWN, current_pos)
          create_and_post_event(LEFT_UP, current_pos)
        end

        def right_click
          current_pos = current_mouse_position
          create_and_post_event(RIGHT_DOWN, current_pos)
          create_and_post_event(RIGHT_UP, current_pos)
        end

        def double_click
          click
          sleep(rand(DOUBLE_CLICK_DURATION_RANGE))
          click
        end

        private

        def create_and_post_event(event_type, point)
          event = CGEventCreateMouseEvent(nil, event_type, point, 0)
          CGEventPost(0, event)
          CFRelease(event)
        end

        def current_mouse_position
          event = CGEventCreate(nil)
          return CGPoint.new if event.null?

          system_point = CGEventGetLocation(event)
          CFRelease(event)

          # Convert the system coordinates to browser coordinates
          browser_x = system_point[:x] / @scale_factor
          browser_y = (@display_height - system_point[:y]) / @scale_factor

          @mouse_position = {
            x: browser_x,
            y: browser_y
          }

          # Return the browser coordinates
          CGPoint.new.tap do |p|
            p[:x] = system_point[:x]
            p[:y] = system_point[:y]
          end
        end

        def convert_coordinates(browser_x, browser_y)
          # Convert the browser coordinates to system coordinates
          system_x = browser_x * @scale_factor
          system_y = @display_height - (browser_y * @scale_factor)

          CGPoint.new.tap do |p|
            p[:x] = system_x
            p[:y] = system_y
          end
        end

        def determine_scale_factor
          # Determine the scale factor for the display
          # By default, the scale factor is 2.0 for Retina displays

          `system_profiler SPDisplaysDataType | grep -i "retina"`.empty? ? 1.0 : 2.0
        rescue StandardError
          2.0 # Default to 2.0 if the scale factor cannot be determined
        end
      end
    end
  end
end

# Test
# require 'chromate/hardwares/mouses/mac_os_controller'
# require 'ostruct'
# element = OpenStruct.new(x: 500, y: 300, width: 100, height: 100)
# mouse = Chromate::Hardwares::Mouse::MacOsController.new(element: element)
# mouse.hover
