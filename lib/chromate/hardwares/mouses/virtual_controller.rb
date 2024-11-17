# frozen_string_literal: true

module Chromate
  module Hardwares
    module Mouses
      class VirtualController < Chromate::Hardwares::MouseController
        def hover # rubocop:disable Metrics/AbcSize
          # Définir la position cible pour le hover autour du centre de l'élément
          target_x = element.x + (element.width / 2) + rand(-20..20)
          target_y = element.y + (element.height / 2) + rand(-20..20)
          start_x = @mouse_position[:x]
          start_y = @mouse_position[:y]
          steps = rand(25..50)
          duration = rand(0.1..0.3)

          # Générer une courbe de Bézier pour le mouvement naturel
          points = bezier_curve(steps: steps, start_x: start_x, start_y: start_y, target_x: target_x, target_y: target_y)

          # Déplacer la souris le long de la courbe de Bézier
          points.each do |point|
            dispatch_mouse_event('mouseMoved', point[:x], point[:y])
            sleep(duration / steps)
          end

          # Mettre à jour la position de la souris
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

          target_x = element.x + (element.width / 2)
          target_y = element.y + (element.height / 2)
          start_x = @mouse_position[:x]
          start_y = @mouse_position[:y]
          steps = rand(25..50)
          duration = rand(0.1..0.3)

          # Générer une courbe de Bézier pour le mouvement naturel
          points = bezier_curve(steps: steps, start_x: start_x, start_y: start_y, target_x: target_x, target_y: target_y)

          # Étape 1 : Début du drag (dragEnter) avec mise à jour de la position de la souris
          move_mouse_to(start_x, start_y)
          dispatch_drag_event('dragEnter', start_x, start_y)

          # Étape 2 : Déplacer la souris le long de la courbe de Bézier (dragOver)
          points.each do |point|
            move_mouse_to(point[:x], point[:y])
            dispatch_drag_event('dragOver', point[:x], point[:y])
            sleep(duration / steps)
          end

          # Étape 3 : Lâcher l'élément (drop)
          move_mouse_to(target_x, target_y)
          dispatch_drag_event('drop', target_x, target_y)

          # Étape 4 : Fin du drag (dragEnd)
          dispatch_drag_event('dragEnd', target_x, target_y)

          # Mettre à jour la position de la souris
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

        def bezier_curve(steps:, start_x:, start_y:, target_x:, target_y:)
          # Points de contrôle pour une courbe plus naturelle
          control_x1 = start_x + (rand(50..150) * (target_x > start_x ? 1 : -1))
          control_y1 = start_y + (rand(50..150) * (target_y > start_y ? 1 : -1))
          control_x2 = target_x + (rand(50..150) * (target_x > start_x ? -1 : 1))
          control_y2 = target_y + (rand(50..150) * (target_y > start_y ? -1 : 1))

          (0..steps).map do |i|
            t = i.to_f / steps
            x = (((1 - t)**3) * start_x) + (3 * ((1 - t)**2) * t * control_x1) + (3 * (1 - t) * (t**2) * control_x2) + ((t**3) * target_x)
            y = (((1 - t)**3) * start_y) + (3 * ((1 - t)**2) * t * control_y1) + (3 * (1 - t) * (t**2) * control_y2) + ((t**3) * target_y)
            { x: x, y: y }
          end
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
