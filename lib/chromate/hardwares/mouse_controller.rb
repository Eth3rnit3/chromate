# frozen_string_literal: true

module Chromate
  module Hardwares
    class MouseController
      CLICK_DURATION_RANGE = (0.01..0.1)
      DOUBLE_CLICK_DURATION_RANGE = (0.1..0.5)

      def self.reset_mouse_position
        @@mouse_position = { x: 0, y: 0 } # rubocop:disable Style/ClassVars
      end

      attr_accessor :element, :client

      # @param [Chromate::Element] element
      # @param [Chromate::Client] client
      def initialize(element: nil, client: nil)
        @element        = element
        @client         = client
      end

      # @return [Hash]
      def mouse_position
        @@mouse_position ||= { x: 0, y: 0 } # rubocop:disable Style/ClassVars
      end

      # @return [self]
      def hover
        raise NotImplementedError
      end

      # @return [self]
      def click
        raise NotImplementedError
      end

      # @return [self]
      def double_click
        raise NotImplementedError
      end

      # @return [self]
      def right_click
        raise NotImplementedError
      end

      # @params [Chromate::Element] element
      # @return [self]
      def drag_and_drop_to(element)
        raise NotImplementedError
      end

      # @return [Integer]
      def position_x
        mouse_position[:x]
      end

      # @return [Integer]
      def position_y
        mouse_position[:y]
      end

      private

      # @return [Integer]
      def target_x
        element.x + (element.width / 2)
      end

      # @return [Integer]
      def target_y
        element.y + (element.height / 2)
      end

      # @param [Integer] steps
      # @return [Array<Hash>]
      def bezier_curve(steps:, start_x: position_x, start_y: position_y, t_x: target_x, t_y: target_y) # rubocop:disable Metrics/AbcSize
        # Points for the Bézier curve
        control_x1 = start_x + (rand(50..150) * (t_x > start_x ? 1 : -1))
        control_y1 = start_y + (rand(50..150) * (t_y > start_y ? 1 : -1))
        control_x2 = t_x + (rand(50..150) * (t_x > start_x ? -1 : 1))
        control_y2 = t_y + (rand(50..150) * (t_y > start_y ? -1 : 1))

        (0..steps).map do |i|
          t = i.to_f / steps
          x = (((1 - t)**3) * start_x) + (3 * ((1 - t)**2) * t * control_x1) + (3 * (1 - t) * (t**2) * control_x2) + ((t**3) * t_x)
          y = (((1 - t)**3) * start_y) + (3 * ((1 - t)**2) * t * control_y1) + (3 * (1 - t) * (t**2) * control_y2) + ((t**3) * t_y)
          { x: x, y: y }
        end
      end

      # @param [Integer] target_x
      # @param [Integer] target_y
      # @return [Hash]
      def update_mouse_position(target_x, target_y)
        @@mouse_position[:x] = target_x
        @@mouse_position[:y] = target_y

        mouse_position
      end
    end
  end
end
