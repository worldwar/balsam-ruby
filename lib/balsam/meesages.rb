require 'bunny'
require 'json'
require 'nokogiri'
require 'open-uri'
require 'balsam/parser'
require 'balsam/actor/actors'
require 'balsam/extractor/mlongtanxs_extractor'

module Balsam
  class Message
    def start
      puts "start connecting..."
      conn = Bunny.new(:hostname => "zhuran.tw", :username => "bookreader", :password => "bookreader")
      conn.start
      puts "connected"
      ch   = conn.create_channel
      x    = ch.direct("bookreadertopic", :durable => true, :auto_delete => false)
      q    = ch.queue("add-book-gdwxcn", :durable => true)
      q.bind(x, :routing_key => "add-book-gdwxcn")

      q2    = ch.queue("add-book-m-longtanxs", :durable => true)
      q2.bind(x, :routing_key => "add-book-m-longtanxs")
      puts "got queue"
      catalog_actor = CatalogActor.new
      begin
        q.subscribe(:block => true) do |delivery_info, properties, body|
          puts " [x] Received #{body}"
          request = JSON.parse(body)
          url = request["url"]
          catalog_actor.catalog(url)
        end

        q2.subscribe(:block => true) do |delivery_info, properties, body|
          puts " [x] Received #{body}"
          request = JSON.parse(body)
          url = request["url"]
          catalog_actor.catalog(url)
        end
      rescue Interrupt => _
        puts "connection broken"
        ch.close
        conn.close
      end
    end
  end
end