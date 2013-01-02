def find_local_image(filename, options={})
  ext = File.extname(filename)
  filename_with_style = "#{ File.basename(filename, ext) }_original#{ ext }"

  Crawler::FileHelper.images(options).each do |image|
    image_filename = File.basename(image)
    if image_filename == filename_with_style || image_filename == File.basename(filename)
      return image if File.exists?(image)
    end
  end
  return nil
end

def find_local_image2(filename, options={})
  ext = File.extname(filename)
  filename_with_style = "#{ File.basename(filename, ext) }_original#{ ext }"

  Crawler::FileHelper.images(options).each do |image|
    image_filename = File.basename(image)
    if image_filename == filename_with_style || image_filename == File.basename(filename)
      return image
    end
  end
  return nil
end

def find_local_image3(filename, options={})
  ext = File.extname(filename)
  filename_with_style = "#{ File.basename(filename, ext) }_original#{ ext }"

  Crawler::FileHelper.images(options).find do |path|
    path.index(filename_with_style) || path.index(filename) && File.exists?(path)
  end
end

def find_local_image4(filename, options={})
  ext = File.extname(filename)
  filename_with_style = "#{ File.basename(filename, ext) }_original#{ ext }"

  Crawler::FileHelper.images(options).each do |image|
    if image.index(filename_with_style) || image.index(filename)
      return image if File.exists?(image)
    end
  end
  return nil
end

Benchmark.bm do |x|
  x.report{ 20.times{ find_local_image('foo.jog', cache: true) } }
  x.report{ 20.times{ find_local_image2('foo2.jog', cache: true) } }
  x.report{ 20.times{ find_local_image3('foo2.jog', cache: true) } }
  x.report{ 20.times{ find_local_image4('foo2.jog', cache: true) } }
end

Benchmark.bm do |x|
  @total = 2_000

  x.report do
    count = 0
    total = @total

    Wallpaper.select('id, image_src').limit(total).all.each_with_index do |wallpaper, count|
      next if wallpaper.image_src.blank?
      Crawler::FileHelper.find_local_image(wallpaper.image_src, cache: true)
    end
  end

  x.report do
    count = 0
    total = @total

    Wallpaper.select('id, image_src').limit(total).all.each_slice(total/5).map do |wallpapers|
      Thread.new do
        wallpapers.each do |wallpaper|
          count += 1

          next if wallpaper.image_src.blank?
          Crawler::FileHelper.find_local_image(wallpaper.image_src, cache: true)
        end
      end
    end.each(&:join)
  end

  x.report do
    total = @total

    threads = []

    Wallpaper.select('id, image_src').limit(total).all.each_slice(total/5) do |wallpapers|
      threads << Thread.new do
        wallpapers.each do |wallpaper|
          next if wallpaper.image_src.blank?
          Crawler::FileHelper.find_local_image(wallpaper.image_src, cache: true)
        end
      end
    end

    threads.each(&:join)
  end
end