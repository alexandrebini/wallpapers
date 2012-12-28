module Crawler
  class Base
    require 'nokogiri'
    require 'open-uri'
    require 'net/http'
    require 'csv'

    attr_accessor :home_url, :listing_pages, :wallpaper_threads

    def initialize(options)
      Wallpapers::Application.config.threadsafe!
      Thread.abort_on_exception = true
      @listing_pages = []
      @wallpaper_threads = []
      @total = 0
      @count = 0
      @home_url = options[:home_url]
      @verification_matcher = options[:verification_matcher]
    end

    def start!
      page = Nokogiri::HTML(open_url @home_url)
      get_listing_pages(page)
      get_wallpapers
      self
    end

    def log(args)
      @logger ||= Logger.new("#{ Rails.root }/log/#{ URI.parse(@home_url).host }.log")
      @logger << args
      puts args
    end

    def fail_log(args)
      @fail_logger ||= Logger.new("#{ Rails.root }/log/#{ URI.parse(@home_url).host }.fail.log")
      @fail_logger << args
      @fail_logger << "\n"
    end

    def open_url(url)
      Crawler::Base.open_url(url, @verification_matcher)
    end

    def get_listing_pages(page)
      slice_size = @listing_pages.size > 4 ? @listing_pages.size/4 : @listing_pages.size

      @listing_pages.each_slice(slice_size).map do |pages|
        Thread.new do
          pages.each{ |page| crawl_listing_page(page) }
        end
      end.each(&:join)
    end

    def crawl_wallpapers(links)
      @total += links.size
      slice_size = links.size > 4 ? links.size/4 : links.size

      if links.size == 0
        puts "######## fuuuuu", url, page
        puts "########"
      end

      links.each_slice(slice_size).each do |links_slice|
        @wallpaper_threads << Thread.new do
          links_slice.each { |link| crawl_wallpaper(link) }
        end
      end
    end

    def get_wallpapers
      @wallpaper_threads.each(&:join)
    end

    def crawl_listing_page(url)
      log "\ncrawling a list of wallpapers from #{ url }"
      begin
        Nokogiri::HTML(open_url url)
      rescue
        log "\nerror on crawling #{ url }. Trying again..."
        retry
      end
    end

    def crawl_wallpaper(link)
      throw 'you should implement crawl_wallpaper method'
    end

    class << self
      def start!
        self.new.start!
      end

      def open_url(url, verification_matcher=nil)
        @denied_proxies ||= []
        max_attempts = 10
        attempts = 0

        begin
          proxy = Crawler::Base.proxy
          proxy_uri = URI.parse(proxy)
          uri = URI.parse(url)
          body = ''

          Net::HTTP::Proxy(proxy_uri.host, proxy_uri.port).start(uri.host) do |http|
            request = Net::HTTP::Get.new(uri.request_uri)
            response = http.request(request)
            unless response.kind_of?(Net::HTTPRedirection)
              if verification_matcher
                body = response.body if response.body.index(verification_matcher)
              else
                body = response.body
              end
            end
            http.finish
          end

          throw "Body is nil for #{ url }" if body.blank?

          # proxy = Crawler::Base.proxy
          # # io = open(url, proxy: proxy)
          # response = io.read
          # io.close

          GC.start
          return body
        rescue Exception => e
          error_logger "\n#{ proxy } #{ e.to_s }. Trying a new proxy..."
          @denied_proxies << proxy unless @denied_proxies.include?(proxy)
          attempts += 1
          retry unless attempts >= max_attempts
        end
      end

      def proxy
        available_proxies = (@proxy_list.to_a - @denied_proxies.to_a)

        if @proxy_list.nil? || available_proxies.size == 0
          error_logger "\nGetting a new proxy list..."
          @denied_proxies = []
          @proxy_list = []

          # get from http://www.checkedproxylists.com/
          CSV.open("#{ Rails.root }/config/proxylist.csv", col_sep: ';').each do |row|
            next if row[3] == 'true'
            ip = row[0].strip
            port = row[1].to_i
            url = "http://#{ ip }:#{ port }"
            begin
              URI.parse(url)
              @proxy_list << url
            rescue
            end
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