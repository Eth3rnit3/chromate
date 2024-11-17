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

        def drag_and_drop_to(element)
          hover

          steps         = rand(25..50)
          mouse_target  = MouseController.new(element: element, client: client)
          points        = mouse_target.send(:bezier_curve, steps: steps)
          duration      = rand(0.1..0.3)

          dispatch_mouse_event('mousePressed', target_x, target_y, button: 'left', click_count: 1)

          points.each do |point|
            dispatch_mouse_event('mouseMoved', point[:x], point[:y])
            sleep(duration / steps)
          end

          dispatch_mouse_event('mouseReleased', points.last[:x], points.last[:y], button: 'left', click_count: 1)

          update_mouse_position(points.last[:x], points.last[:y])
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
