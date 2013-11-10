class WallpaperDownload
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(wallpaper_id)
    Timeout.timeout(10.minutes.to_i) do
      wallpaper = Wallpaper.find(wallpaper_id)

      unless wallpaper.downloading?
        download_logger "\nWallpaper #{ wallpaper.id } is not downloading. Current status: #{ wallpaper.status }", wallpaper
        return
      end

      @filename = File.basename(wallpaper.image_src)
      @local_image = Crawler::FileHelper.find_local_image(@filename)
      if @local_image
        source = 'local'
        file = File.open(@local_image)
      else
        source = 'remote'
        file = StringIO.new(Crawler::UrlOpener.instance.open_url wallpaper.image_src,
          proxy: false, min_size: 22.kilobytes, image: true)
      end

      wallpaper.image = file
      wallpaper.image_file_name = @filename
      wallpaper.status = 'downloaded'
      wallpaper.colors.destroy_all

      if wallpaper.save
        download_logger "\nWallpaper #{ wallpaper.id } image: #{ wallpaper.image_src } (#{ source })", wallpaper
      else
        raise wallpaper.errors.full_messages.join(' ')
      end
    end
  rescue Timeout::Error
    if wallpaper
      wallpaper.status = 'pending'
      wallpaper.save(validate: false)
      download_logger "\nTimeout on wallpaper #{ wallpaper.id }: #{ wallpaper.image_src } (#{ source })", wallpaper
    end
  rescue Exception => e
    if wallpaper
      wallpaper.status = 'pending'
      wallpaper.save(validate: false)
      download_logger "\nError on wallpaper #{ wallpaper.id }: #{ wallpaper.image_src } (#{ source }). #{ e }" + e.backtrace.join("\n"), wallpaper
    else
      download_logger "\nError on wallpaper #{ wallpaper_id } (#{ source }). #{ e }"
    end
    return false
  ensure
    file.close rescue nil
    Crawler::FileHelper.delete_local_image(@local_image) if @local_image
  end

  def download_logger(msg, wallpaper=nil)
    logger = if wallpaper.present?
      Logger.new("#{ Rails.root }/log/#{ wallpaper.source.name }.downloads.log")
    else
      Logger.new("#{ Rails.root }/log/download_error.log")
    end
    puts msg
    logger << msg
  end
end