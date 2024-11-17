# frozen_string_literal: true

require 'ffi'
require 'chromate/helpers'

module X11
  extend FFI::Library
  ffi_lib 'X11'

  # Types
  typedef :ulong, :Window
  typedef :pointer, :Display

  # X11 functions
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

  # Constants
  REVERT_TO_PARENT = 2
end

module Xtst
  extend FFI::Library
  ffi_lib 'Xtst'

  attach_function :XTestFakeButtonEvent, %i[pointer uint int ulong], :int
end
