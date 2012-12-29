class WallpaperDownload
  include Crawler::UrlOpener

  @queue = :wallpapers_queue

  class << self
    def perform(wallpaper_id, image_url)
      wallpaper = Wallpaper.find(wallpaper_id)
      filename = image_url[image_url.rindex('/')+1..-1]

      file = StringIO.new(open_url image_url, proxy: false)
      p file

      wallpaper.image = file
      wallpaper.image_file_name = filename
      wallpaper.save

      download_logger "\nWallpaper #{ wallpaper.id } image: #{ image_url }"
    rescue Exception => e
      download_logger "\nError on wallpaper #{ wallpaper.id }: #{ image_url }. #{ e }"
      return false
    ensure
      file.close
    end

    def download_logger(msg)
      @download_logger ||= Logger.new("#{ Rails.root }/log/download_error.log")
      puts msg
      @download_logger << msg
    end
  end
end