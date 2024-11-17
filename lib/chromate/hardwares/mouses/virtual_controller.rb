# frozen_string_literal: true

module Chromate
  module Hardwares
    module Mouses
      class VirtualController < Chromate::Hardwares::MouseController
        def hover
          steps     = rand(25..50)
          points    = bezier_curve(steps: steps)
          duration  = rand(0.1..0.3)

          points.each do |point|
            dispatch_mouse_event('mouseMoved', point[:x], point[:y])
            sleep(duration / steps)
          end

          update_mouse_position(points.last[:x], points.last[:y])
        end

        def click
          hover
          click!
        end

        def double_click
          click
          sleep(rand(DOUBLE_CLICK_DURATION_RANGE))
          click
        end

        def right_click
          hover
          dispatch_mouse_event('mousePressed', target_x, target_y, button: 'right', click_count: 1)
          sleep(rand(CLICK_DURATION_RANGE))
          dispatch_mouse_event('mouseReleased', target_x, target_y, button: 'right', click_count: 1)
        end

        def drag_and_drop_to(element) # rubocop:disable Metrics/AbcSize
          hover

          target_x = element.x + (element.width / 2)
          target_y = element.y + (element.height / 2)
          start_x = @mouse_position[:x]
          start_y = @mouse_position[:y]
          steps = 50
          duration = rand(0.1..0.3)

          # Step 1: Start the drag (dragEnter) with updating the mouse position
          move_mouse_to(start_x, start_y)
          dispatch_drag_event('dragEnter', start_x, start_y)

          # Step 2: Move the mouse in a straight line to the target element (dragOver)
          x_step = (target_x - start_x) / steps.to_f
          y_step = (target_y - start_y) / steps.to_f

          (1..steps).each do |i|
            new_x = start_x + (x_step * i)
            new_y = start_y + (y_step * i)

            # Update the mouse position
            move_mouse_to(new_x, new_y)

            # Send the dragOver event
            dispatch_drag_event('dragOver', new_x, new_y)
            sleep(duration / steps)
          end

          # Step 3: Drop the element (drop)
          move_mouse_to(target_x, target_y)
          dispatch_drag_event('drop', target_x, target_y)

          # Step 4: End the drag (dragEnd)
          dispatch_drag_event('dragEnd', target_x, target_y)

          # Step 5: Update the mouse position
          update_mouse_position(target_x, target_y)
        end

        private

        def click!
          dispatch_mouse_event('mousePressed', target_x, target_y, button: 'left', click_count: 1)
          sleep(rand(CLICK_DURATION_RANGE))
          dispatch_mouse_event('mouseReleased', target_x, target_y, button: 'left', click_count: 1)
        end

        # @param [String] type mouseMoved, mousePressed, mouseReleased
        # @param [Integer] target_x
        # @param [Integer] target_y
        # @option [String] button
        # @option [Integer] click_count
        def dispatch_mouse_event(type, target_x, target_y, button: 'none', click_count: 0)
          params = {
            type: type,
            x: target_x,
            y: target_y,
            button: button,
            clickCount: click_count,
            deltaX: 0,
            deltaY: 0,
            modifiers: 0,
            timestamp: (Time.now.to_f * 1000).to_i
          }

          client.send_message('Input.dispatchMouseEvent', params)
        end

        # @param [Integer] steps
        # @param [Integer] x
        # @param [Integer] y
        # @return [Array<Hash>]
        def dispatch_drag_event(type, x, y) # rubocop:disable Naming/MethodParameterName
          params = {
            type: type,
            x: x,
            y: y,
            data: {
              items: [
                {
                  mimeType: 'text/plain',
                  data: 'dragged'
                }
              ],
              dragOperationsMask: 1
            }
          }

          client.send_message('Input.dispatchDragEvent', params)
        end

        # @param [Integer] x
        # @param [Integer] y
        # @return [self]
        def move_mouse_to(x, y) # rubocop:disable Naming/MethodParameterName
          params = {
            type: 'mouseMoved',
            x: x,
            y: y,
            button: 'none',
            clickCount: 0,
            deltaX: 0,
            deltaY: 0,
            modifiers: 0,
            timestamp: (Time.now.to_f * 1000).to_i
          }

          client.send_message('Input.dispatchMouseEvent', params)

          self
        end

        def update_mouse_position(target_x, target_y)
          @mouse_position[:x] = target_x
          @mouse_position[:y] = target_y
        end
      end
    end
  end
end

# Test
# require 'chromate/hardwares/mouses/virtual_controller'
# require 'ostruct'
# element = OpenStruct.new(x: 500, y: 300, width: 100, height: 100)
# mouse = Chromate::Hardwares::Mouse::VirtualController.new(element: element)
# mouse.hover
