class WallpaperDownload
  include Crawler::UrlOpener

  @queue = :wallpapers_queue

  class << self
    def perform(wallpaper_id)
      wallpaper = Wallpaper.find(wallpaper_id)
      filename = File.basename(wallpaper.image_src)

      local_image = find_local_image(filename)
      if local_image
        file = File.open(local_image)
      else
        file = StringIO.new(open_url wallpaper.image_src, proxy: false)
      end

      wallpaper.image = file
      wallpaper.image_file_name = filename
      wallpaper.save

      source = local_image ? 'local' : 'remote'
      download_logger "\nWallpaper #{ wallpaper.id } image: #{ wallpaper.image_src } (#{ source })"
    rescue Exception => e
      download_logger "\nError on wallpaper #{ wallpaper.id }: #{ wallpaper.image_src } (#{ source }). #{ e }"
      return false
    ensure
      file.close if file
      delete_local_image(local_image) if local_image
    end

    def download_logger(msg)
      @download_logger ||= Logger.new("#{ Rails.root }/log/download_error.log")
      puts msg
      @download_logger << msg
    end

    def find_local_image(filename)
      wallpapers_dir = "#{ Rails.root }/public/system/wallpapers"
      images = Dir["#{ wallpapers_dir }/**/*"].reject { |fn| File.directory?(fn) }

      ext = File.extname(filename)
      file_with_style = "#{ File.basename(filename, ext) }_original#{ ext }"

      images.each do |image|
        if File.basename(image) == file_with_style
          return image if File.exists?(image)
        end
      end
      return nil
    end

    def delete_local_image(path)
      File.delete(path) if File.exists?(path)
      dir = path.gsub(File.basename(path), '')
      remove_empty_dir(dir)

      parent_dir = dir.gsub(dir.split('/').last, '')
      remove_empty_dir(parent_dir)
    end

    def remove_empty_dir(dir)
      if Dir.exists?(dir)
        Dir.delete(dir) if Dir["#{ dir }/**/*"].empty?
      end
    end
  end
end