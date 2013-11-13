module Crawler
  class Interfacelift
    extend Crawler::ActMacro

    acts_as_crawler

    def source
      @source ||= Source.where(
        name: 'InterfaceLIFT',
        url: 'http://interfacelift.com',
        start_url: 'http://interfacelift.com/wallpaper/downloads/date/any/',
        verification_matcher: 'ca-pub-3902458398606385'
      ).first_or_create
    end

    def pages_urls(page)
      pagination = page.css('div.pagenums_bottom a.selector')
      total_pages = pagination[pagination.count-2].content.to_i

      Array.new.tap do |pages|
        pages << source.start_url
        2.upto(total_pages).each do |page|
          pages << "#{ source.url }/wallpaper/downloads/date/any/index#{ page }.html"
        end
      end
    end

    def wallpapers_urls(page)
      page.css('div.item div.preview a').map do |link|
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
      page.css('h1 a').first.content
    end

    def parse_tags(page)
      page.css('.jeder p a').map do |tag|
        next unless tag.attr(:href).match(/tags/)
        next if tag.content.blank?

        name = tag.content.gsub(' »', '').downcase.strip
        begin
          Tag.where(name: name).first_or_create
        rescue ActiveRecord::RecordNotUnique
          retry
        end
      end.compact.uniq
    end

    def parse_image(options)
      resolutions = options[:page].css('div.download select option').map do |option|
        resolution = option.content.match(/([0-9]*)x([0-9]*)/).to_s
        next if resolution.blank?

        # get the url from preview
        # http://interfacelift.com/wallpaper/previews/03165_sunsetcliffs.jpg
        # http://interfacelift.com/wallpaper/D47cd523/03165_sunsetcliffs_1440x900.jpg
        preview_url = options[:page].css('link[rel="image_src"]').first.attr(:href)
        extension = File.extname(preview_url)
        preview_url.gsub('previews', '7yz4ma1').
          gsub(extension, "_#{ resolution }#{ extension }")
      end.compact.uniq

      ['1204x768', '1280x800', '1280x960', ''].each do |preferred_resolution|
        resolution = resolutions.find{ |url| url.match(preferred_resolution) }
        return resolution unless resolution.blank?
      end
    end
  end
end