require 'celluloid'
require 'balsam/parser'

module Balsam
  @@parser = Parser.new

  def self.parser
    @@parser
  end

  class CatalogActor
    include Celluloid

    def initialize
      @size = 10
      @paragraph_actors = Array.new(@size){ParagraphActor.new}
    end

    def catalog(url)
      book_object = Balsam::parser.parse(url)
      book_object.save
      dispatch(book_object)
    end

    def dispatch(book_object)
      i = 0
      book_object.volumes.each do |volume|
        volume.chapters.each do |chapter|
          begin
            actor = @paragraph_actors[i % @size]
            i += 1
            actor.paragraph(chapter.chapter_id, chapter.original_url, self)
            sleep 0.1
          rescue => e
            puts e.backtrace
          end
        end
      end
    end

    def complete_paragraph(chapter, paragraph_id)
      c = Chapter.find_by_chapter_id(chapter)
      c.paragraph_id = paragraph_id
      c.save
    end
  end

  class ParagraphActor
    include Celluloid
    def initialize

    end

    def paragraph(chapter, url, sender)
      paragraph = Balsam::parser.paragraph(url)
      paragraph.save
      sender.complete_paragraph(chapter, paragraph.paragraph_id)
    end
  end
end