require 'nokogiri'
require 'open-uri'
require 'addressable'
require 'balsam/db/book'
require 'balsam/util'

module Balsam
  class Parser
    def parse(url)
      page = Nokogiri::HTML(open(url))
      # puts page
      title = page.css('.gw_breadcrumb a').last.text
      book_id = Util.randomHash
      author = '未知'

      book = Book.new
      book.book_id = book_id
      book.title = title
      book.author = author
      book.original_url = url
      book.create_date = DateTime.current
      book.import_date = book.create_date

      volumes = []
      chapter_seq = 0
      volume_seq = 0
      page.css('.zhangjie').each do |v|
        volume_id = Util.randomHash
        volume = Volume.new
        volume.volume_id = volume_id
        volume.title = ''
        volume.book_id = book_id
        volume.seq = volume_seq
        volume_seq += 1
        chapters = []

        v.css('li a').each do |c|
          base = Addressable::URI.parse(url)
          link = base + c['href']
          title = c.text
          chapter = Chapter.new
          chapter.chapter_id = Util.randomHash
          chapter.title = title
          chapter.book_id = book_id
          chapter.volume_id = volume_id
          chapter.seq = chapter_seq
          chapter_seq += 1
          chapter.original_url = link

          chapters.push(chapter)
        end
        volume_object = VolumeObject.new(volume: volume, chapters: chapters)
        volumes.push(volume_object)
      end
      BookObject.new(book: book, volumes: volumes)
    end

    def paragraph(url)
      html = open(url).read
      page = Nokogiri::HTML(Util.to_utf8(html))
      e = page.css('.xstext pre')
      e = page.css('.xstext') if e.empty?
      content = e.text
      paragraph = Paragraph.new
      paragraph.paragraph_id = Util.randomHash
      paragraph.content = content
      paragraph
    end
  end
end