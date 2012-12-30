class WallpaperDownload
  include Crawler::UrlOpener

  @queue = :wallpapers_queue

  class << self
    def perform(wallpaper_id)
      wallpaper = Wallpaper.find(wallpaper_id)
      filename = wallpaper.image_src[wallpaper.image_src.rindex('/')+1..-1]

      file = StringIO.new(open_url wallpaper.image_src, proxy: false)

      wallpaper.image = file
      wallpaper.image_file_name = filename
      wallpaper.save

      download_logger "\nWallpaper #{ wallpaper.id } image: #{ wallpaper.image_src }"
    rescue Exception => e
      download_logger "\nError on wallpaper #{ wallpaper.id }: #{ wallpaper.image_src }. #{ e }"
      return false
    ensure
      file.close if file
    end

    def download_logger(msg)
      @download_logger ||= Logger.new("#{ Rails.root }/log/download_error.log")
      puts msg
      @download_logger << msg
    end
  end
end