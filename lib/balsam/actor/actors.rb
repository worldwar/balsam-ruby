require 'celluloid'
require 'balsam/parser'
require 'balsam/extractor/mlongtanxs_extractor'

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
      @paragraph_extractor_actors = Array.new(@size){ParagraphExtractorActor.new}
    end

    def catalog(url)
      if url.include? "gdxsw"
        book_object = Balsam::parser.parse(url)
        book_object.save
        dispatch(book_object)
      else
        extractor = extractor(url)
        book_meta = extractor.extract_book(url)
        puts "book meta: #{book_meta}"
        book = save_book(book_meta, url)
        puts "book: #{book}"
        dispatch_tasks(book, extractor)
      end
    end

    def save_book(book_meta, url)
      book = Book.new
      book_id = Util.randomHash
      book.book_id = book_id
      book.title = book_meta.title
      book.author = book_meta.author
      book.original_url = url
      book.create_date = DateTime.current
      book.import_date = book.create_date

      volumes = book_meta.volumes.each_with_index.map do |v, volume_index|
        volume = Volume.new
        volume_id = Util.randomHash
        volume.volume_id = volume_id
        volume.title = v.title
        volume.book_id = book_id
        volume.seq = volume_index

        chapters = v.chapters.each_with_index.map do |c, chapter_index|
          chapter = Chapter.new
          chapter.chapter_id = Util.randomHash
          chapter.title = c.title
          chapter.book_id = book_id
          chapter.volume_id = volume_id
          chapter.seq = chapter_index
          chapter.original_url = c.url
          chapter
        end
        VolumeObject.new(volume: volume, chapters: chapters)
      end
      book_object = BookObject.new(book: book, volumes: volumes)
      book_object.save
      book_object
    end

    def dispatch_tasks(book, extractor)
      i = 0
      book.volumes.each do |volume|
        volume.chapters.each do |chapter|
          begin
            actor = @paragraph_extractor_actors[i % @size]
            i += 1
            actor.paragraph(extractor, chapter.chapter_id, chapter.original_url, self)
            sleep 0.1
          rescue => e
            puts e.backtrace
          end
        end
      end
    end

    def extractor(url)
      MlongtanxsExtractor.new
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

  class ParagraphExtractorActor
    include Celluloid
    def initialize

    end

    def paragraph(extractor, chapter, url, sender)
      paragraph = extractor.extract_paragraph(url)
      p = save_paragraph(paragraph)
      sender.complete_paragraph(chapter, p.paragraph_id)
    end

    def save_paragraph(content)
      paragraph = Paragraph.new
      paragraph.paragraph_id = Util.randomHash
      paragraph.content = content
      paragraph.save
      paragraph
    end
  end
end