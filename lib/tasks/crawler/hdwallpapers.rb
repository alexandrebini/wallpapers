module Crawler
  class Hdwallpapers
    require 'nokogiri'
    require 'open-uri'

    attr_accessor :listing_pages, :wallpaper_threads, :home_url

    def self.start!
      self.new.start!
    end

    def initialize
      @listing_pages = []
      @wallpaper_threads = []
      @total = 0
      @count = 0
      @home_url = 'http://www.hdwallpapers.in'

    end

    def start!
      page = Nokogiri::HTML(open(@home_url))
      get_listing_pages(page)
      get_wallpapers
      self
    end

    private
      def get_listing_pages(page)
        pages = page.css('div.pagination a')
        # total_pages = pages[pages.count-2].content.to_i
        total_pages = 3

        @listing_pages << home_url
        2.upto(total_pages).each do |page|
          @listing_pages << "#{ home_url }/latest_wallpapers/page/#{ page }"
        end

        @listing_pages.each_slice(50).map do |pages|
          Thread.new do
            pages.each{ |page| crawl_listing_page(page) }
          end
        end.each(&:join)
      end

      def crawl_listing_page(url)
        puts "\ncrawling a list of wallpapers from #{ url }"
        page = Nokogiri::HTML(open(url))

        @wallpaper_threads << Thread.new do
          links = page.css('ul.wallpapers li a')
          @total += links.size
          links.each do |link|
            crawl_wallpaper "#{ home_url }#{ link.attr(:href) }"
          end
        end
      end

      def get_wallpapers
        @wallpaper_threads.each(&:join)
      end

      def crawl_wallpaper(url)
        puts "\ncrawling wallpaper #{ @count += 1 }/#{ @total } from #{ url }"
        page = Nokogiri::HTML(open(url))

        wallpaper = Wallpaper.new
        page.css('ul.tags li a').each do |tag|
          wallpaper.tags << Tag.find_or_create_by_name(tag.name.downcase)
        end

        title = page.css('.wallpaper-ads-right').to_s.match(/<b>Wallpaper:<\/b>.*?<br>/).to_a.first
        wallpaper.title = title.gsub('<b>Wallpaper:</b> ', '').gsub('<br>', '')
      end

  end
end