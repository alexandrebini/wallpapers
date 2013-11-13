module Crawler
  class Hdwallpapers
    extend Crawler::ActMacro

    acts_as_crawler

    def source
      @source ||= Source.where(
        name: 'HDWallpapers',
        url: 'http://www.hdwallpapers.in',
        start_url: 'http://www.hdwallpapers.in',
        verification_matcher: 'UA-5746983-2'
      ).first_or_create
    end

    def pages_urls(page)
      pages = page.css('div.pagination a')
      total_pages = pages[pages.count-2].content.to_i

      Array.new.tap do |pages|
        pages << source.start_url
        2.upto(total_pages).each do |page|
          pages << "#{ source.url }/latest_wallpapers/page/#{ page }"
        end
      end
    end

    def wallpapers_urls(page)
      page.css('ul.wallpapers li a').map do |link|
        if link.attr(:href).match('http://')
          link.attr(:href)
        else
          "#{ source.url }#{ link.attr(:href) }"
        end
      end
    end

    def parse_wallpaper(options)
      Wallpaper.create(
        image_src: options[:image_src],
        source: source,
        source_url: options[:url],
        tags: parse_tags(options[:page]),
        title: parse_title(options[:page])
      )
    end

    def parse_title(page)
      page.css('.wallpaper-ads-right').to_s.
        match(/<b>Wallpaper:<\/b>.*?<br>/).to_a.first.
        gsub('<b>Wallpaper:</b> ', '').gsub('<br>', '')
    end

    def parse_tags(page)
      page.css('ul.tags li a').map do |tag|
        begin
          Tag.where(name: tag.content.downcase).first_or_create
        rescue ActiveRecord::RecordNotUnique
          retry
        end
      end
    end

    def parse_image(options)
      resolutions = options[:page].css('.wallpaper-resolutions a').map do |resolution|
        href = resolution.attr('href')
        if href.match('http://')
          href
        else
          "#{ source.url }#{ href }"
        end
      end

      ['1204x768', '1280x800', '1280x960', ''].each do |preferred_resolution|
        resolution = resolutions.find{ |url| url.match(preferred_resolution) }
        return resolution unless resolution.blank?
      end
    end
  end
end