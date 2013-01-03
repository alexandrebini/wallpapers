require "#{ Rails.root }/app/workers/wallpaper_download"

namespace :crawler do
  desc 'import wallpapers from hdwallpapers.in'
  task start: :environment do
    [
      Thread.new{ Crawler::Goodfon.start! },
      Thread.new{ Crawler::Hdwallpapers.start! },
      Thread.new{ Crawler::Interfacelift.start! }
    ].each(&:join)
  end

  desc 'start downloads'
  task download: :environment do
    jobs = Resque.workers.count

    if jobs == 0
      puts "Please start resque: COUNT=10 QUEUE=* rake resque:workers"
    else
      puts "Starting #{ jobs } jobs..."
      Wallpaper.pending.random.limit(jobs).each do |wallpaper|
        wallpaper.download_image
      end
    end
  end

  desc 'restart downloads'
  task restart_downloads: :environment do
    Thread.abort_on_exception = true

    # clear wallpapers
    Wallpaper.update_all(image_file_name: nil, image_content_type: nil,
      image_file_size: nil, image_updated_at: nil, image_meta: nil,
      image_fingerprint: nil)

    # clean colors
    Color.connection.execute "TRUNCATE TABLE wallpapers_colors;"
    Color.connection.execute "TRUNCATE TABLE colors;"
    Color.destroy_all
    Wallpaper.update_all(status: 'pending')

    count = 0
    total_downloaded = 0
    total = Wallpaper.count

    Wallpaper.select('id, image_src').all.each_slice(Wallpaper.count/10).map do |wallpapers|
      Thread.new do
        wallpapers.each do |wallpaper|
          count += 1
          puts "Restart downloads: #{ count }/#{ total }" if count % 500 == 0

          next if wallpaper.image_src.blank?

          if Crawler::FileHelper.find_local_image(wallpaper.image_src, cache: true)
            total_downloaded += 1
            wallpaper.download_image
          end
        end
      end
    end.each(&:join)

    puts "let's work..."
    puts "#{ total_downloaded } downloaded"
    puts "#{ total - total_downloaded } to download"
  end
end