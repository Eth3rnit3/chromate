# frozen_string_literal: true

require 'ffi'
require 'chromate/helpers'

module X11
  extend FFI::Library
  ffi_lib 'X11'

  # Types
  typedef :ulong, :Window
  typedef :pointer, :Display

  # Fonctions X11
  attach_function :XOpenDisplay, [:string], :pointer
  attach_function :XCloseDisplay, [:pointer], :int
  attach_function :XDefaultRootWindow, [:pointer], :ulong
  attach_function :XWarpPointer, %i[pointer ulong ulong int int uint uint int int], :int
  attach_function :XQueryPointer, %i[pointer ulong pointer pointer pointer pointer pointer pointer pointer], :bool
  attach_function :XFlush, [:pointer], :int
  attach_function :XQueryTree, %i[pointer ulong pointer pointer pointer pointer], :int
  attach_function :XFetchName, %i[pointer ulong pointer], :int
  attach_function :XFree, [:pointer], :int
  attach_function :XRaiseWindow, %i[pointer ulong], :int
  attach_function :XSetInputFocus, %i[pointer ulong int ulong], :int

  # Constantes
  RevertToParent = 2
end

module Xtst
  extend FFI::Library
  ffi_lib 'Xtst'

  attach_function :XTestFakeButtonEvent, %i[pointer uint int ulong], :int
end

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
          current_mouse_position
        end

        def click
          hover
          simulate_button_event(LEFT_BUTTON, true)
          simulate_button_event(LEFT_BUTTON, false)
        end

        def right_click
          simulate_button_event(RIGHT_BUTTON, true)
          simulate_button_event(RIGHT_BUTTON, false)
        end

        def double_click
          click
          sleep(rand(DOUBLE_CLICK_DURATION_RANGE))
          click
        end

        private

        def smooth_move_to(dest_x, dest_y)
          start_pos = current_mouse_position
          start_x = start_pos[:x]
          start_y = start_pos[:y]

          distance = Math.hypot(dest_x - start_x, dest_y - start_y)
          steps = [distance / 5, 10].max.to_i # Assure un minimum de 10 étapes

          steps.times do |step|
            t = (step + 1) / steps.to_f
            # Interpolation linéaire (peut être améliorée avec des courbes pour plus de naturel)
            current_x = start_x + ((dest_x - start_x) * t)
            current_y = start_y + ((dest_y - start_y) * t)

            X11.XWarpPointer(@display, 0, @root_window, 0, 0, 0, 0, current_x.to_i, current_y.to_i)
            X11.XFlush(@display)
            sleep(0.005 + (rand * 0.01)) # Pause entre les mouvements pour simuler le comportement humain
          end
        end

        def focus_chrome_window
          chrome_window = find_window_by_name(@root_window, 'Chrome')
          if chrome_window == 0
            puts 'Aucune fenêtre Chrome trouvée'
          else
            X11.XRaiseWindow(@display, chrome_window)
            X11.XSetInputFocus(@display, chrome_window, X11::RevertToParent, 0)
            X11.XFlush(@display)
          end
        end

        def find_window_by_name(window, name)
          root_return = FFI::MemoryPointer.new(:ulong)
          parent_return = FFI::MemoryPointer.new(:ulong)
          children_return = FFI::MemoryPointer.new(:pointer)
          nchildren_return = FFI::MemoryPointer.new(:uint)

          status = X11.XQueryTree(@display, window, root_return, parent_return, children_return, nchildren_return)
          return 0 if status == 0

          nchildren = nchildren_return.read_uint
          children_ptr = children_return.read_pointer

          return 0 if nchildren == 0 || children_ptr.null?

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
            # Recherche récursive dans les fenêtres enfants
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
