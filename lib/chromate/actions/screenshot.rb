# frozen_string_literal: true

module Chromate
  module Actions
    module Screenshot
      def screenshot(file_path = "#{Time.now.to_i}.png", options = {})
        return xvfb_screenshot(file_path) if @xfvb
        return screenshot_full_page(file_path, options) if options.delete(:full_page)

        image_data = make_screenshot(options)
        File.binwrite(file_path, image_data)
        true
      end

      private

      def xvfb_screenshot(file_path)
        display = ENV['DISPLAY'] || ':99'
        system("xwd -root -display #{display} | convert xwd:- #{file_path}")
      end

      def screenshot_full_page(file_path, options = {})
        metrics = @client.send_message('Page.getLayoutMetrics')

        content_size = metrics['contentSize']
        width = content_size['width'].ceil
        height = content_size['height'].ceil

        @client.send_message('Emulation.setDeviceMetricsOverride', {
                               mobile: false,
                               width: width,
                               height: height,
                               deviceScaleFactor: 1
                             })

        screenshot(file_path, options)

        @client.send_message('Emulation.clearDeviceMetricsOverride')
        true
      end

      def make_screenshot(options = {})
        default_options = {
          format: 'png',
          fromSurface: true
        }

        params = default_options.merge(options)

        @client.send_message('Page.enable')

        result = @client.send_message('Page.captureScreenshot', params)

        image_data = result['data']
        Base64.decode64(image_data)
      end
    end
  end
end
