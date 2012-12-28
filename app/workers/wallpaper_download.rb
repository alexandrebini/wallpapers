class WallpaperDownload
  @queue = :wallpapers_queue

  class << self
    def perform(wallpaper_id, image_url)
      wallpaper = Wallpaper.find(wallpaper_id)
      wallpaper.image = Crawler::Base.open_url(image_url)
      wallpaper.image_file_name = image_url[image_url.rindex('/')+1..-1]
      wallpaper.save

      if wallpaper.colors.blank?
        Miro.options[:color_count] = 4
        Miro.options[:image_magick_path] = '/usr/local/bin/convert'

        colors = Miro::DominantColors.new(wallpaper.image.path)
        colors.to_hex.each do |hex|
          hex = hex.gsub('#', '')
          wallpaper.colors << Color.find_or_create_by_hex(hex)
        end
      end
    end
  end
end