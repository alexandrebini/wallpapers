require "#{ Rails.root }/lib/crawler/crawler"

class WallpaperDownload
  @queue = :wallpapers_queue

  class << self
    def perform(wallpaper_id)
      wallpaper = Wallpaper.find(wallpaper_id)

      unless wallpaper.downloading?
        download_logger "\nWallpaper #{ wallpaper.id } is not downloading. Current status: #{ wallpaper.status }"
        return
      end

      filename = File.basename(wallpaper.image_src)
      local_image = Crawler::FileHelper.find_local_image(filename)
      if local_image
        source = 'local'
        file = File.open(local_image)
      else
        source = 'remote'
        file = StringIO.new(open_url wallpaper.image_src, proxy: false, min_size: 22.kilobytes, image: true)
      end

      wallpaper.image = file
      wallpaper.image_file_name = filename
      wallpaper.status = 'downloaded'
      wallpaper.colors.destroy_all

      if wallpaper.save
        download_logger "\nWallpaper #{ wallpaper.id } image: #{ wallpaper.image_src } (#{ source })"
      else
        raise wallpaper.errors.full_messages.join(' ')
      end
    rescue Exception => e
      if wallpaper
        wallpaper.status = 'pending'
        wallpaper.save(validate: false)
        download_logger "\nError on wallpaper #{ wallpaper.id }: #{ wallpaper.image_src } (#{ source }). #{ e }" + e.backtrace.join("\n")

      else
        download_logger "\nError on wallpaper #{ wallpaper_id } (#{ source }). #{ e }"
      end
      return false
    ensure
      file.close if file
      Crawler::FileHelper.delete_local_image(local_image) if local_image
      add_next_wallpaper_to_queue(source)
    end

    def download_logger(msg)
      @download_logger ||= Logger.new("#{ Rails.root }/log/download_error.log")
      puts msg
      @download_logger << msg
    end

    def add_next_wallpaper_to_queue(source=nil)
      if Wallpaper.pending.count > 0 && source != 'local'
        Wallpaper.pending.random.first.download_image
      end
    end
  end
end