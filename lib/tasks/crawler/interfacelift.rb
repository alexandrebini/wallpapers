# encoding: utf-8
module Crawler
  class Interfacelift < Crawler::Base
    def initialize
      super(
        home_url: 'http://interfacelift.com/',
        verification_matcher: 'ca-pub-3902458398606385'
      )
    end

    def get_listing_pages(page)
      first_page = 'http://interfacelift.com/wallpaper/downloads/date/any/'
      page = Nokogiri::HTML(open_url first_page)

      pages = page.css('div.pagenums_bottom a.selector')
      total_pages = pages[pages.count-2].content.to_i

      @listing_pages << first_page
      2.upto(total_pages).each do |page|
        @listing_pages << "#{ @home_url }/wallpaper/downloads/date/any/index#{ page }.html"
      end

      super(page)
    end

    def crawl_listing_page(url)
      page = super(url)
      links = page.css('div.item div.preview a').map do |link|
        if link.attr(:href).match('http://')
          link.attr(:href)
        else
          "#{ @home_url }#{ link.attr(:href) }"
        end
      end
      crawl_wallpapers(links)
    rescue Exception => e
      fail_log "\n#{ url }\t#{ e.to_s }\n"
    end

    def crawl_wallpaper(url)
      log "\ncrawling wallpaper #{ @count += 1 }/#{ @total } from #{ url }"
      page = Nokogiri::HTML(open_url url)

      image_src = parse_image(page)
      return if Wallpaper.where(image_src: image_src).exists?

      wallpaper = Wallpaper.create(
        image_src: image_src,
        source: @home_url,
        tags: parse_tags(page),
        title: parse_title(page)
      )
    rescue Exception => e
      fail_log "\n#{ url }\t#{ e.to_s }\n"
    end

    def parse_title(page)
      page.css('h1 a').first.content
    end

    def parse_tags(page)
      page.css('.jeder p a').map do |tag|
        if tag.attr(:href).match(/tags/)
          next if tag.content.blank?
          name = tag.content.gsub(' »', '').downcase.strip
          Tag.find_or_create_by_name(name)
        end
      end.compact.uniq
    end

    def parse_image(page)
      # find max resolution
      max_resolution = { width: 0, height: 0, size: nil }
      page.css('div.download select option').map do |option|
        resolution = option.content.match(/([0-9]*)x([0-9]*)/).to_s.split('x')
        next if resolution.blank?
        width = resolution.first.to_i
        height = resolution.last.to_i
        if width > max_resolution[:width]
          max_resolution = { width: width, height: height, size: "#{ width }x#{ height }"}
        end
      end

      # get the url from preview
      # http://interfacelift.com/wallpaper/previews/03165_sunsetcliffs.jpg
      # http://interfacelift.com/wallpaper/D47cd523/03165_sunsetcliffs_1440x900.jpg
      preview_url = page.css('link[rel="image_src"]').first.attr(:href)
      extension = File.extname(preview_url)
      preview_url.gsub('previews', 'D47cd523').
        gsub(extension, "_#{ max_resolution[:size] }#{ extension }")
    end
  end
end