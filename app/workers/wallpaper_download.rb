class WallpaperDownload
  include Crawler::UrlOpener

  @queue = :wallpapers_queue

  class << self
    def perform(wallpaper_id)
      wallpaper = Wallpaper.find(wallpaper_id)
      filename = File.basename(wallpaper.image_src)

      local_image = Crawler::FileHelper.find_local_image(filename)
      if local_image
        file = File.open(local_image)
      else
        file = StringIO.new(open_url wallpaper.image_src, proxy: false)
      end

      wallpaper.image = file
      wallpaper.image_file_name = filename
      wallpaper.save
      wallpaper.colors.destroy_all

      source = local_image ? 'local' : 'remote'
      download_logger "\nWallpaper #{ wallpaper.id } image: #{ wallpaper.image_src } (#{ source })"
    rescue Exception => e
      download_logger "\nError on wallpaper #{ wallpaper.id }: #{ wallpaper.image_src } (#{ source }). #{ e }"
      return false
    ensure
      file.close if file
      Crawler::FileHelper.delete_local_image(local_image) if local_image
    end

    def download_logger(msg)
      @download_logger ||= Logger.new("#{ Rails.root }/log/download_error.log")
      puts msg
      @download_logger << msg
    end
  end
end