namespace :wallpapers do
  desc 'status'
  task status: :environment do
    include ActionView::Helpers::NumberHelper
    sources = Source.all.sort_by{ |r| r.wallpapers.downloaded.count }.reverse
    sources.each do |source|
      downloaded = "downloaded: #{ number_with_delimiter source.wallpapers.downloaded.count }"
      downloading = "downloading: #{ number_with_delimiter source.wallpapers.downloading.count }"
      pending = "pending: #{ number_with_delimiter source.wallpapers.pending.count }"
      puts "#{ source.slug.ljust(15) } #{ downloaded.ljust(25) } #{ downloading.ljust(25) } #{ pending.ljust(25) }"
    end

    downloaded = "downloaded: #{ number_with_delimiter Wallpaper.downloaded.count }"
    downloading = "downloading: #{ number_with_delimiter Wallpaper.downloading.count }"
    pending = "pending: #{ number_with_delimiter Wallpaper.pending.count }"
    puts "#{ 'Total'.ljust(15) } #{ downloaded.ljust(25) } #{ downloading.ljust(25) } #{ pending.ljust(25) }"

    sleep(60)
    puts
    redo
  end

  desc 'Cleanup'
  task cleanup: :environment do
    wallpapers = Wallpaper.downloaded
    corrupted = []
    slice_size = wallpapers.count / 4 rescue 1
    wallpapers.each_slice(slice_size).map do |wallpapers_slice|
      Thread.new do
        wallpapers_slice.each do |wallpaper|
          case
          when File.exists?(wallpaper.image.path) == false
            corrupted.push wallpaper
          when File.extname(wallpaper.image.path) == '.jpg' && system("jpeginfo -c \"#{ wallpaper.image.path }\" | grep -E \"WARNING|ERROR\"")
            corrupted.push wallpaper
          end
        end
      end
    end.each(&:join)

    corrupted.each do |wallpaper|
      wallpaper.image.destroy
      wallpaper.download_image
    end

    puts "#{ corrupted.count }/#{ wallpapers.count } corrupted"
  end
end