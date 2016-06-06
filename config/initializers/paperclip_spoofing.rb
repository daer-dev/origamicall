# Paperclip 4 tiene un bug con el "spoof detector", que da falsos positivos:
# https://github.com/thoughtbot/paperclip/issues/1429

require 'paperclip/media_type_spoof_detector'

module Paperclip
  class MediaTypeSpoofDetector
    def spoofed?
      false
    end
  end
end