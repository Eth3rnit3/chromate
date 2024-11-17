# frozen_string_literal: true

module Chromate
  module Hardwares
    module Keyboards
      class VirtualController < Chromate::Hardwares::KeyboardController
        def press_key(key = 'Enter')
          params = {
            key: key,
            code: key_to_code(key),
            windowsVirtualKeyCode: key_to_virtual_code(key)
          }

          params[:text] = key if key.length == 1

          # Dispatch keyDown event
          client.send_message('Input.dispatchKeyEvent', params.merge(type: 'keyDown'))

          # Dispatch keyUp event
          client.send_message('Input.dispatchKeyEvent', params.merge(type: 'keyUp'))

          self
        end

        private

        # @param [String] key
        # @return [String]
        def key_to_code(key)
          case key
          when 'Enter' then 'Enter'
          when 'Tab' then 'Tab'
          when 'Backspace' then 'Backspace'
          when 'Delete' then 'Delete'
          when 'Escape' then 'Escape'
          when 'ArrowLeft' then 'ArrowLeft'
          when 'ArrowRight' then 'ArrowRight'
          when 'ArrowUp' then 'ArrowUp'
          when 'ArrowDown' then 'ArrowDown'
          else
            "Key#{key.upcase}"
          end
        end

        # @param [String] key
        # @return [Integer]
        def key_to_virtual_code(key)
          case key
          when 'Enter' then 0x0D
          when 'Tab' then 0x09
          when 'Backspace' then 0x08
          when 'Delete' then 0x2E
          when 'Escape' then 0x1B
          when 'ArrowLeft' then 0x25
          when 'ArrowRight' then 0x27
          when 'ArrowUp' then 0x26
          when 'ArrowDown' then 0x28
          else
            key.upcase.ord
          end
        end
      end
    end
  end
end
