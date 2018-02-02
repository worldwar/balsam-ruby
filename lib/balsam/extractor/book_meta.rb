require 'balsam/util'

module Balsam
  class BookMeta
    attr_accessor :title, :author, :volumes
  end

  class VolumeMeta
    attr_accessor :title, :seq, :chapters
  end

  class ChapterMeta
    attr_accessor :title, :url
  end
end