namespace :crawler do
  desc 'import wallpapers from hdwallpapers.in'
  task start: :environment do
    [
      Thread.new{ Crawler::Goodfon.start! },
      Thread.new{ Crawler::Hdwallpapers.start! }
    ].each(&:join)
  end

  desc 'this task move downloaded files to /wallpapers/downloads, set all images attributes to nil, and create a queue priorizing images that are already downloaded. Remenber to send order=(asc|desc)'
  task restart_downloads: :move_downloaded_files do
    # clear wallpapers
    Wallpaper.update_all(image_file_name: nil, image_content_type: nil,
      image_file_size: nil, image_updated_at: nil, image_meta: nil,
      image_fingerprint: nil)

    wallpapers_to_download = []
    wallpapers_downloaded = []

    # priorize images already downloaded
    Color.connection.execute "TRUNCATE TABLE wallpapers_colors;"
    Color.connection.execute "TRUNCATE TABLE colors;"
    Color.destroy_all

    Wallpaper.all.each_slice(Wallpaper.count/30).map do |wallpapers|
      Thread.new do
        wallpapers.each do |wallpaper|
          next if wallpaper.image_src.blank?

          if Crawler::FileHelper.find_local_image(wallpaper.image_src, cache: true)
            wallpapers_downloaded << wallpaper
          else
            wallpapers_to_download << wallpaper
          end
        end
      end
    end.each(&:join)

    puts "#{ wallpapers_downloaded } downloaded"
    puts "#{ wallpapers_to_download.size } to download"

    # add new remove images
    order = ENV['order'] || 'asc'
    wallpapers_to_download.sort_by!{ |wallpaper| wallpaper.id }
    wallpapers_to_download.reverse! if order == 'desc'
    wallpapers_to_download.shuffle.each do |wallpaper|
      Resque.enqueue(WallpaperDownload, wallpaper.id)
    end

    wallpapers_downloaded.each do |wallpaper|
      Resque.enqueue(WallpaperDownload, wallpaper.id)
    end
  end

  desc 'move downloaded files from /wallpapers/ to /wallpapers/downloads'
  task move_downloaded_files: :environment do
    # move download files to wallpapers/downloads folder
    downloads_dir = "#{ Rails.root }/public/system/wallpapers/downloads"
    FileUtils.mkdir_p downloads_dir
    images = Crawler::FileHelper.images.reject { |file| file.match(downloads_dir) }
    images.each do |path|
      begin
        FileUtils.mv path, downloads_dir
        Crawler::FileHelper.remove_empty_dir path
      rescue Exception => e
        puts e.to_s
      end
    end

    system "cd #{ Rails.root } && RAILS_ENV=#{ Rails.env } rake crawler:clean_empty_folders"
  end

  desc 'find empty folders and delete it'
  task clean_empty_folders: :environment do
    dir = "#{ Rails.root }/public/system/wallpapers"
    Dir.glob("#{dir}/**/", File::FNM_DOTMATCH).count do |d|
      begin
        Dir.rmdir(d)
      rescue SystemCallError
      end
    end
    system "find #{dir} -type d -empty -exec rmdir '{}'" rescue nil
  end

  desc 'copy downloaded files to other dir. This is useful to copy to external disk'
  task copy_downloaded_files: :environment do
    source_dir = "#{ Rails.root }/public/system/wallpapers"
    target_dir = '/Volumes/BINI/wallpapers'
    FileUtils.mkdir_p target_dir

    images = Crawler::FileHelper.images
    count = 0
    total = images.size

    images.each_slice(images.size/10).map do |images_slice|
      Thread.new do
        images_slice.each do |path|
          puts "#{ count += 1 }/#{ total }"
          begin
            filename = File.basename(path)
            target_path = "#{ target_dir }/#{ filename }"
            next if File.exists?(target_path) && File.size(target_path) > File.size(path)
            FileUtils.cp path, target_dir
          rescue Exception => e
            puts e.to_s
          end
        end
      end
    end.each(&:join)
  end

  desc 'check if each image is valid. This is done by checking the percentage of gray (#808080) of the file'
  task check_images_integrity: :environment do
    source_dir = '/Volumes/BINI/wallpapers'
    target_dir = '/Volumes/BINI/wallpapers-to-check'
    FileUtils.mkdir_p target_dir

    images = Crawler::FileHelper.images(dir: source_dir)
    count = 0
    total = images.size

    images.each_slice(images.size/5).map do |images_slice|
      Thread.new do
        images_slice.each do |path|
          puts "#{ count += 1 }/#{ total }"
          unless Crawler::FileHelper.valid_image?(path, min_size: 22.kilobytes)
            FileUtils.mv path, target_dir
          end
        end
      end
    end.each(&:join)
  end
end