require 'digest'
require 'rchardet19'

module Balsam
  class Util
    def self.randomHash()
      md5 = Digest::MD5.new
      md5 << Random.new.bytes(10)
      md5.hexdigest
    end

    def self.to_utf8(text)
      cd = CharDet.detect(text)
      if cd.confidence > 0.6
        text.force_encoding(cd.encoding)
      end
      text.encode!("utf-8", :undef => :replace, :replace => "?", :invalid => :replace)
      return text
    end
  end
end