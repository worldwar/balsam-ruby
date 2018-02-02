require 'balsam/util'
require 'balsam/extractor/book_meta'
require 'balsam/extractor/extractor'

module Balsam
  class MlongtanxsExtractor < Extractor
    def extract_book(url)
      catalog_url = make_catalog_url(url)
      catalog_base = Addressable::URI.parse(catalog_url)

      page = Nokogiri::HTML(open(url))
      catalog_page = Util.page_utf8(catalog_url)

      book_meta = BookMeta.new
      book_meta.title = extract_title(page)
      book_meta.author = extract_author(page)
      book_meta.volumes = extract_volumes(catalog_page, catalog_base)
      book_meta
    end

    def make_catalog_url(url)
      matchers = /(.*\/wapbook\/)(.*)\.html/.match(url)
      base_url = matchers[1]
      original_book_id = matchers[2]
      base_url + original_book_id + "/"
    end

    def extract_paragraph(url)
      page = Util.page_utf8(url)
      page.css("#chaptercontent").last.text
    end

    def extract_title(page)
      Util.to_utf8(page.css('.title').last.text)
    end

    def extract_author(page)
      title = Util.to_utf8(page.css('.author').last.text)
      title[3..-1]
    end

    def extract_chapters(page, catalog_base)
      chapters = []
      chapter_items = page.css('#chapterlist p')
      chapter_items.each do |chapter_item|
        chapter_link = chapter_item.css('a').last
        chapter_url = chapter_link['href']
        if chapter_url.start_with? "/wapbook"
          chapter_meta = ChapterMeta.new
          chapter_meta.title = Util.to_utf8(chapter_link.text)
          chapter_meta.url = catalog_base + chapter_url
          chapters.append(chapter_meta)
        end
      end
      chapters
    end

    def extract_volumes(page, catalog_base)
      volume_meta = VolumeMeta.new
      volume_meta.chapters = extract_chapters(page, catalog_base)
      [volume_meta]
    end
  end
end