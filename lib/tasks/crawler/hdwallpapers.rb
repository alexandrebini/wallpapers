require 'base'
module Crawler
  class Hdwallpapers < Crawler::Base
    def initialize
      super(
        home_url: 'http://www.hdwallpapers.in/',
        verification_matcher: 'ykbm8cEoYeNB0RI8VEbksy7+KGBNbzO8MZkfJ+H3Sqg='
      )
    end

    def get_listing_pages(page)
      pages = page.css('div.pagination a')
      total_pages = pages[pages.count-2].content.to_i

      @listing_pages << @home_url
      2.upto(total_pages).each do |page|
        @listing_pages << "#{ @home_url }/latest_wallpapers/page/#{ page }"
      end

      super(page)
    end

    def crawl_listing_page(url)
      page = super(url)
      links = page.css('ul.wallpapers li a').map do |link|
        if link.attr(:href).match('http://')
          link.attr(:href)
        else
          "#{ @home_url }#{ link.attr(:href) }"
        end
      end
      crawl_wallpapers(links)
    end

    def crawl_wallpaper(url)
      return if Wallpaper.where(source_url: url).exists?

      log "\ncrawling wallpaper #{ @count += 1 }/#{ @total } from #{ url }"
      page = Nokogiri::HTML(open_url url)

      image_src = parse_image(page)
      return if Wallpaper.where(image_src: image_src).exists?

      wallpaper = Wallpaper.create(
        image_src: image_src,
        source: parse_source,
        source_url: url,
        tags: parse_tags(page),
        title: parse_title(page)
      )
    rescue Exception => e
      fail_log "\n#{ url }\t#{ e.to_s }\n"
    end

    def parse_source
      @source ||= Source.find_or_create_by_name_and_url('HD Wallpapers', 'http://www.hdwallpapers.in')
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
      if page.css('.thumbbg1 a').first
        path = page.css('.thumbbg1 a').first.attr(:href)
      else
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
      end

      if path.match('http://')
        path
      else
        "#{ @home_url }#{ path }"
      end
    end
  end
end