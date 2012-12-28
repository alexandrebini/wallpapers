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
        @error_logger ||= Logger.new("#{ Rails.root }/log/crawler_error.log")
        begin
          proxy = Crawler::Base.proxy
          open(url, proxy: proxy)
        rescue OpenURI::HTTPError => e
          @error_logger << "\n#{ e.to_s }. #{ proxy } Trying a new proxy..."
          retry
        rescue Exception => e
          @error_logger << "\n#{ e.to_s }. #{ proxy }"
          retry
        end
      end

      def proxy
        list = %w(
          189.80.168.162:8080
          186.225.129.162:3128
          177.19.217.220:8080
          187.6.254.19:3128
          200.205.218.149:3128
          177.99.172.82:8080
          200.208.251.210:8080
          200.182.190.146:8080
        )
        return "http://#{ list.sample }"
      end
    end
  end
end