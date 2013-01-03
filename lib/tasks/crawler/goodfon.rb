require "#{ Rails.root }/lib/tasks/crawler/base"
module Crawler
  class Goodfon < Crawler::Base
    def initialize
      super(
        home_url: 'http://www.goodfon.com/',
        verification_matcher: 'Wfwlp7OYsTa-e2sWDO8BDZUvVReSFI42Dnr3RPNoeTQ'
      )
    end

    def get_listing_pages(page)
      total_pages = page.css('.pageinfoen div').first.content.to_i

      @listing_pages << @home_url
      2.upto(total_pages).each do |page|
        @listing_pages << "#{ @home_url }index-#{ page }.html"
      end

      super(page)
    end

    def crawl_listing_page(url)
      page = super(url)
      links = page.css('div.tabl_td > div > a').map do |a|
        a.attr(:href)
      end
      crawl_wallpapers(links)
    end

    def crawl_wallpaper(url)
      log "\ncrawling wallpaper #{ @count += 1 }/#{ @total } from #{ url }"
      page = Nokogiri::HTML(open_url url)

      image_src = parse_image(page, url)
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
      @source ||= Source.find_or_create_by_name_and_url('GoodFon', 'http://www.goodfon.com')
    end

    def parse_title(page)
    end

    def parse_tags(page)
      page.xpath('/html/body/div[1]/div[9]/div[3]/div/div/a').map do |tag|
        Tag.find_or_create_by_name(tag.content.downcase)
      end
    end

    def parse_image(page, url)
      id = url.scan(/\d+/).first
      resolution = page.xpath('/html/body/div[1]/div[9]/div[2]/div/table/tr/td[3]/a').first.content.strip
      "http://wallpaper.goodfon.com/image/#{ id }-#{ resolution }.jpg"
    end
  end
end