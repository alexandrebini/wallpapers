module Crawler
  class Base
    require 'nokogiri'
    require 'open-uri'

    attr_accessor :home_url

    def log(args)
      @logger ||= Logger.new("#{ Rails.root }/log/#{ URI.parse(@home_url).host }.log")
      @logger << args
      puts args
    end

    def open_url(url)
      Crawler::Base.open_url(url)
    end

    class << self
      def open_url(url)
        @denied_proxies ||= []

        begin
          proxy = Crawler::Base.proxy
          io = open(url, proxy: proxy)
          file = io.read
          io.close
          return file
        rescue Exception => e
          error_logger "\n#{ proxy } #{ e.to_s }. Trying a new proxy..."
          @denied_proxies << proxy unless @denied_proxies.include?(proxy)
          retry
        end
      end

      def proxy
        # list = %w(
        #   189.80.168.162:8080
        #   186.225.129.162:3128
        #   177.19.217.220:8080
        #   187.6.254.19:3128
        #   200.205.218.149:3128
        #   177.99.172.82:8080
        #   200.208.251.210:8080
        #   200.182.190.146:8080
        # )
        p @proxy_list, @denied_proxies.to_a, (@proxy_list.to_a - @denied_proxies.to_a)
        puts

        if @proxy_list.nil? || (@proxy_list.to_a - @denied_proxies.to_a).size == 0
          error_logger "\nGetting a new proxy list..."
          # file = open('http://www.xroxy.com/proxylist.php?port=80&type=All_http&ssl=nossl&country=BR&latency=&reliability=#table')
          # file = open('http://www.xroxy.com/proxylist.php?port=80&type=All_http&ssl=nossl&latency=&reliability=#table')
          # file = open('http://www.xroxy.com/proxylist.php?port=80&type=All_http&ssl=nossl&country=&latency=1000&reliability=9000#table')
          file = open('http://www.xroxy.com/proxylist.php?port=80&type=All_http&ssl=nossl&country=US&latency=1000&reliability=9000#table')
          doc = Nokogiri::HTML(file)
          file.close

          @proxy_list = doc.css('tr.row0, tr.row1').map do |tr|
            ip = tr.css('td')[1].content.gsub('\n', '').strip
            port = tr.css('td')[2].content.to_i
            "http://#{ ip }:#{ port }"
          end
        end

        return (@proxy_list - @denied_proxies.to_a).sample
      end

      def error_logger(msg)
        @error_logger ||= Logger.new("#{ Rails.root }/log/crawler_error.log")
        @error_logger << msg
      end
    end
  end
end