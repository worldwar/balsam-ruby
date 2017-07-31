require 'active_record'

ActiveRecord::Base.establish_connection(
    :adapter => "postgresql",
    :host => "localhost",
    :database => "readinglist",
    :user => "readinglist_dev",
    :password => "readinglist_dev"
)

module Balsam

  class Book < ActiveRecord::Base
    self.table_name = 'book'
    self.primary_key = 'key'
  end

  class Volume < ActiveRecord::Base
    self.table_name = 'volume'
    self.primary_key = 'key'

  end

  class Chapter < ActiveRecord::Base
    self.table_name = 'chapter'
    self.primary_key = 'key'

  end

  class Paragraph < ActiveRecord::Base
    self.table_name = 'paragraph'
    self.primary_key = 'key'

  end

  class BookObject
    attr_accessor :book
    attr_accessor :volumes
    def initialize(book:, volumes:)
      @book     = book
      @volumes   = volumes
    end

    def save()
      @book.save
      @volumes.each do |volume|
        volume.volume.save
        volume.chapters.each do |chapter|
          chapter.save
        end
      end
    end
  end

  class VolumeObject
    attr_accessor :volume
    attr_accessor :chapters

    def initialize(volume:, chapters:)
      @volume = volume
      @chapters = chapters
    end
  end
end