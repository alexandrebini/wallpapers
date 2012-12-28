module Crawler
  class Hdwallpapers < Crawler::Base

    attr_accessor :listing_pages, :wallpaper_threads

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
      page = Nokogiri::HTML(open_url @home_url)
      get_listing_pages(page)
      get_wallpapers
      self
    end

    private
      def get_listing_pages(page)
        pages = page.css('div.pagination a')
        total_pages = pages[pages.count-2].content.to_i
        # total_pages = 1

        @listing_pages << @home_url
        2.upto(total_pages).each do |page|
          @listing_pages << "#{ @home_url }/latest_wallpapers/page/#{ page }"
        end

        @listing_pages.each_slice(50).map do |pages|
          Thread.new do
            pages.each{ |page| crawl_listing_page(page) }
          end
        end.each(&:join)
      end

      def crawl_listing_page(url)
        log "\ncrawling a list of wallpapers from #{ url }"
        page = Nokogiri::HTML(open_url url)

        links = page.css('ul.wallpapers li a')
        @total += links.size

        links.each_slice(4) do |links_slice|
          @wallpaper_threads << Thread.new do
            links_slice.each do |link|
              crawl_wallpaper "#{ @home_url }#{ link.attr(:href) }"
            end
          end
        end
      end

      def get_wallpapers
        @wallpaper_threads.each(&:join)
      end

      def crawl_wallpaper(url)
        page = Nokogiri::HTML(open_url url)

        wallpaper = Wallpaper.new(
          image_url: parse_image(page),
          source: @home_url,
          tags: parse_tags(page),
          title: parse_title(page)
        )

        log "\ncrawling wallpaper #{ @count += 1 }/#{ @total } from #{ url }\t#{ wallpaper.save } #{ wallpaper.id }"
      end

      def parse_title(page)
        page.css('.wallpaper-ads-right').to_s.
          match(/<b>Wallpaper:<\/b>.*?<br>/).to_a.first.
          gsub('<b>Wallpaper:</b> ', '').gsub('<br>', '')
      end

      def parse_tags(page)
        page.css('ul.tags li a').map do |tag|
          Tag.find_or_create_by_name(tag.content.downcase)
        end
      end

      def parse_image(page)
        bigger_resolution = { width: 0, url: nil }
        page.css('.wallpaper-resolutions a').each do |link|
          if link.content == 'Original'
            bigger_resolution = { width: 'original', url: link.attr(:href) }
            break
          else
            width = link.content.split('x').first.to_i
            if width > bigger_resolution[:width]
              bigger_resolution = { width: width, url: link.attr(:href) }
            end
          end
        end

        if bigger_resolution[:url].match(/(.jpg|.png)$/)
          path = bigger_resolution[:url]
        else
          # /view/2013_grand_theft_auto_gta_v-2560x1440.html =>
          # /wallpapers/2013_grand_theft_auto_gta_v-1280x800.jpg
          path = bigger_resolution[:url].gsub('/view/', '/wallpapers').gsub('.html', '.jpg')
        end

        return "#{ @home_url }#{ path }"
      end
  end
end