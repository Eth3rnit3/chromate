# frozen_string_literal: true

require 'chromate/c_logger'
require 'chromate/hardwares/keyboard_controller'
require 'chromate/hardwares/mouse_controller'
require 'chromate/hardwares/mouses/virtual_controller'
require 'chromate/hardwares/keyboards/virtual_controller'
require 'chromate/helpers'

module Chromate
  module Hardwares
    extend Helpers

    # @param [Hash] args
    # @option args [Chromate::Client] :client
    # @option args [Chromate::Element] :element
    # @return [Chromate::Hardwares::MouseController]
    def mouse(**args)
      browser = args[:client].browser
      if browser.options[:native_control]
        if mac?
          Chromate::CLogger.log('🐁 Loading MacOs mouse controller')
          require 'chromate/hardwares/mouses/mac_os_controller'
          return Mouses::MacOsController.new(**args)
        end
        if linux?
          Chromate::CLogger.log('🐁 Loading Linux mouse controller')
          require 'chromate/hardwares/mouses/linux_controller'
          return Mouses::LinuxController.new(**args)
        end
        raise 'Native mouse controller is not supported on Windows' if windows?
      else
        Chromate::CLogger.log('🐁 Loading Virtual mouse controller')
        Mouses::VirtualController.new(**args)
      end
    end
    module_function :mouse

    # @param [Hash] args
    # @option args [Chromate::Client] :client
    # @option args [Chromate::Element] :element
    # @return [Chromate::Hardwares::KeyboardController]
    def keyboard(**args)
      Chromate::CLogger.log('⌨️ Loading Virtual keyboard controller')
      Keyboards::VirtualController.new(**args)
    end
    module_function :keyboard
  end
end
