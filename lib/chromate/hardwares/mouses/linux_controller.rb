# frozen_string_literal: true

require 'chromate/helpers'
require_relative 'x11'

module Chromate
  module Hardwares
    module Mouses
      class LinuxController < MouseController
        class InvalidPlatformError < StandardError; end
        include Helpers

        LEFT_BUTTON = 1
        RIGHT_BUTTON = 3

        def initialize(element: nil, client: nil)
          raise InvalidPlatformError, 'MouseController is only supported on Linux' unless linux?

          super
          @display = X11.XOpenDisplay(nil)
          raise 'Impossible d\'ouvrir l\'affichage X11' if @display.null?

          @root_window = X11.XDefaultRootWindow(@display)
        end

        def hover
          focus_chrome_window
          smooth_move_to(target_x, target_y)
          update_mouse_position(target_x, target_y)
        end

        def click
          hover
          simulate_button_event(LEFT_BUTTON, true)
          sleep(rand(CLICK_DURATION_RANGE))
          simulate_button_event(LEFT_BUTTON, false)
        end

        def right_click
          hover
          simulate_button_event(RIGHT_BUTTON, true)
          sleep(rand(CLICK_DURATION_RANGE))
          simulate_button_event(RIGHT_BUTTON, false)
        end

        def double_click
          click
          sleep(rand(DOUBLE_CLICK_DURATION_RANGE))
          click
        end

        def drag_and_drop_to(element)
          hover

          target_x = element.x + (element.width / 2)
          target_y = element.y + (element.height / 2)
          start_x = position_x
          start_y = position_y
          steps = rand(25..50)
          duration = rand(0.1..0.3)

          # Generate a Bézier curve for natural movement
          points = bezier_curve(steps: steps, start_x: start_x, start_y: start_y, t_x: target_x, t_y: target_y)

          # Step 1: Press the left mouse button
          simulate_button_event(LEFT_BUTTON, true)
          sleep(rand(CLICK_DURATION_RANGE))

          # Step 2: Drag the element
          points.each do |point|
            move_mouse_to(point[:x], point[:y])
            sleep(duration / steps)
          end

          # Step 3: Release the left mouse button
          simulate_button_event(LEFT_BUTTON, false)

          # Update the mouse position
          update_mouse_position(target_x, target_y)

          self
        end

        private

        def smooth_move_to(dest_x, dest_y)
          start_x = position_x
          start_y = position_y

          steps = rand(25..50)
          duration = rand(0.1..0.3)

          # Build a Bézier curve for natural movement
          points = bezier_curve(steps: steps, start_x: start_x, start_y: start_y, t_x: dest_x, t_y: dest_y)

          # Move the mouse along the Bézier curve
          points.each do |point|
            move_mouse_to(point[:x], point[:y])
            sleep(duration / steps)
          end
        end

        def move_mouse_to(x, y)
          X11.XWarpPointer(@display, 0, @root_window, 0, 0, 0, 0, x.to_i, y.to_i)
          X11.XFlush(@display)
        end

        def focus_chrome_window
          chrome_window = find_window_by_name(@root_window, 'Chrome')
          if chrome_window.zero?
            Chromate::CLogger.log('No Chrome window found')
          else
            X11.XRaiseWindow(@display, chrome_window)
            X11.XSetInputFocus(@display, chrome_window, X11::REVERT_TO_PARENT, 0)
            X11.XFlush(@display)
          end
        end

        def find_window_by_name(window, name)
          root_return = FFI::MemoryPointer.new(:ulong)
          parent_return = FFI::MemoryPointer.new(:ulong)
          children_return = FFI::MemoryPointer.new(:pointer)
          nchildren_return = FFI::MemoryPointer.new(:uint)

          status = X11.XQueryTree(@display, window, root_return, parent_return, children_return, nchildren_return)
          return 0 if status.zero?

          nchildren = nchildren_return.read_uint
          children_ptr = children_return.read_pointer

          return 0 if nchildren.zero? || children_ptr.null?

          children = children_ptr.get_array_of_ulong(0, nchildren)
          found_window = 0

          children.each do |child|
            window_name_ptr = FFI::MemoryPointer.new(:pointer)
            status = X11.XFetchName(@display, child, window_name_ptr)
            if status != 0 && !window_name_ptr.read_pointer.null?
              window_name = window_name_ptr.read_pointer.read_string
              if window_name.include?(name)
                X11.XFree(window_name_ptr.read_pointer)
                found_window = child
                break
              end
              X11.XFree(window_name_ptr.read_pointer)
            end
            # Recursive search for the window
            found_window = find_window_by_name(child, name)
            break if found_window != 0
          end

          X11.XFree(children_ptr)
          found_window
        end

        def current_mouse_position
          root_return = FFI::MemoryPointer.new(:ulong)
          child_return = FFI::MemoryPointer.new(:ulong)
          root_x = FFI::MemoryPointer.new(:int)
          root_y = FFI::MemoryPointer.new(:int)
          win_x = FFI::MemoryPointer.new(:int)
          win_y = FFI::MemoryPointer.new(:int)
          mask_return = FFI::MemoryPointer.new(:uint)

          X11.XQueryPointer(@display, @root_window, root_return, child_return, root_x, root_y, win_x, win_y, mask_return)

          { x: root_x.read_int, y: root_y.read_int }
        end

        def simulate_button_event(button, press)
          Xtst.XTestFakeButtonEvent(@display, button, press ? 1 : 0, 0)
          X11.XFlush(@display)
        end

        def finalize
          X11.XCloseDisplay(@display) if @display && !@display.null?
        end
      end
    end
  end
end
