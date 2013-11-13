module Crawler
  class Goodfon
    extend Crawler::ActMacro

    acts_as_crawler

    def source
      @source ||= Source.where(
        name: 'GoodFon',
        url: 'http://www.goodfon.com',
        start_url: 'http://www.goodfon.com',
        verification_matcher: 'Wfwlp7OYsTa-e2sWDO8BDZUvVReSFI42Dnr3RPNoeTQ'
      ).first_or_create
    end

    def pages_urls(page)
      total_pages = page.css('.pageinfoen div').first.content.to_i

      Array.new.tap do |pages|
        pages << @source.start_url
        2.upto(total_pages).each do |page|
          pages << "#{ source.url }/index-#{ page }.html"
        end
      end
    end

    def wallpapers_urls(page)
      page.css('div.tabl_td > div > a').map do |a|
        a.attr(:href)
      end
    end

    def parse_wallpaper(options)
      Wallpaper.create(
        image_src: options[:image_src],
        source: source,
        source_url: options[:url],
        tags: parse_tags(options[:page]),
        title: parse_title(options[:url])
      )
    end

    def parse_title(url)
      url.split('/').last.gsub(/-|_/, ' ').gsub('.html', '').strip.titleize
    end

    def parse_image(options)
      thumb_url = options[:page].xpath('//*[@id="img"]/img').attr('src').value
      id = thumb_url.split('/').last.scan(/\d+/).first
      "http://#{ URI.parse(thumb_url).host }/image/#{ id }-1024x768.jpg"
    end

    private
    def parse_tags(page)
      page.xpath('/html/body/div[1]/div[9]/div[3]/div/div/a').map do |tag|
        next if tag.content.blank?
        begin
          Tag.where(name: tag.content.downcase).lock(true).first_or_create
        rescue ActiveRecord::RecordNotUnique
          retry
        end
      end.compact.uniq
    end
  end
end