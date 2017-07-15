require 'bunny'
require 'json'
require 'nokogiri'
require 'open-uri'

module Balsam
  class Message
    def start
      puts "start connecting..."
      # conn = Bunny.new(:hostname => "zhuran.tw", :username => "bookreader", :password => "bookreader")
      conn = Bunny.new("amqp://nndnyskp:5XbTiDjKSbmQ1fHGg4KUUQhIh-BLz9hL@white-swan.rmq.cloudamqp.com/nndnyskp")
      conn.start
      puts "connected"
      ch   = conn.create_channel
      x    = ch.direct("bookreadertopic", :durable => true, :auto_delete => false)
      q    = ch.queue("add-book", :durable => true)
      q.bind(x, :routing_key => "add-book")
      puts "got queue"

      begin
        q.subscribe(:block => true) do |delivery_info, properties, body|
          puts " [x] Received #{body}"

          request = JSON.parse(body)

          url = request["url"]
          puts url

          h = Nokogiri::HTML(open(url))

          puts h
          # cancel the consumer to exit
          delivery_info.consumer.cancel
        end
      rescue Interrupt => _
        puts "connection broken"
        ch.close
        conn.close
      end
    end
  end
end