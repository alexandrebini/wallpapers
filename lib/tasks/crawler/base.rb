require "#{ Rails.root }/lib/tasks/crawler/url_opener"
require 'nokogiri'

module Crawler
  class Base
    include Crawler::UrlOpener

    attr_accessor :home_url, :listing_pages, :wallpaper_threads

    def initialize(options)
      Wallpapers::Application.config.threadsafe!
      Wallpaper.connection.execute "SET GLOBAL max_connections = 10000000;"
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

    def open_url(url, options={})
      default_options = { verification_matcher: @verification_matcher, proxy: true }
      options.merge!(default_options)
      Crawler::Base.open_url(url, options)
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
    end
  end
end