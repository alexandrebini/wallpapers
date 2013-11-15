require "#{ Rails.root }/lib/crawler/crawler"

namespace :crawler do
  desc 'import all wallpapers'
  task start: :environment do
    [
      Thread.new{ Crawler::Goodfon.start! },
      Thread.new{ Crawler::Hdwallpapers.start! },
      Thread.new{ Crawler::Interfacelift.start! }
    ].each(&:join)
  end

  desc 'start downloads'
  task download: :environment do
    jobs = 10
    puts "Starting #{ jobs } jobs..."
    Wallpaper.pending.random.limit(jobs).each do |wallpaper|
      wallpaper.download_image
    end
  end

  desc 'restart downloads'
  task restart_downloads: :environment do
    Thread.abort_on_exception = true

    reset_wallpapers_attributes!
    move_images_to_tmp!
    cleanup_images_dir!

    queue = enqueue_local_wallpapers

    puts "let's work..."
    puts "#{ queue[:total_downloaded] } downloaded"
    puts "#{ queue[:total] - queue[:total_downloaded] } to download"
    Rake::Task['crawler:download'].invoke
  end

  def reset_wallpapers_attributes!
    # clear wallpapers
    Wallpaper.update_all(image_file_name: nil, image_content_type: nil,
      image_file_size: nil, image_updated_at: nil, image_meta: nil,
      image_fingerprint: nil)

    # clean colors
    Color.connection.execute "TRUNCATE TABLE wallpapers_colors;"
    Color.connection.execute "TRUNCATE TABLE colors;"
    Color.destroy_all
    Wallpaper.update_all(status: 'pending')
  end

  def move_images_to_tmp!
    tmp_dir = "#{ Rails.root }/public/system/wallpapers_tmp"
    FileUtils.mkdir_p tmp_dir

    Dir["#{ Rails.root }/public/system/wallpapers/**/*_original.*"].each do |file|
      FileUtils.mv file, tmp_dir
    end
  end

  def cleanup_images_dir!
    puts "Are you sure you want to delete the wallpapers dir? 5 seconds to think about it..."
    sleep(5)
    FileUtils.rm_rf "#{ Rails.root }/public/system/wallpapers/"
  end

  def enqueue_local_wallpapers
    count = 0
    result = { total: Wallpaper.count, total_downloaded: 0 }
    unless result[:total].zero?
      slice_size = result[:total] > 10 ? result[:total]/10 : 10

      Wallpaper.select('id, image_src').all.each_slice(slice_size).map do |wallpapers|
        Thread.new do
          wallpapers.each do |wallpaper|
            count += 1
            puts "Restart downloads: #{ count }/#{ result[:total] }" if count % 500 == 0

            next if wallpaper.image_src.blank?

            if Crawler::FileHelper.find_local_image(wallpaper.image_src, cache: true)
              result[:total_downloaded] += 1
              wallpaper.download_image
            end
          end
        end
      end.each(&:join)
    end
    result
  end
end