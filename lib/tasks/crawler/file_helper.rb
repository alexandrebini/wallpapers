module Crawler
  module FileHelper
    class << self
      def images
        wallpapers_dir = "#{ Rails.root }/public/system/wallpapers"
        Dir["#{ wallpapers_dir }/**/*"].reject { |fn| File.directory?(fn) }
      end

      def find_local_image(filename)
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
        unless File.extname(dir).blank?
          dir = dir.gsub(File.basename(dir), '')
        end

        if Dir.exists?(dir)
          begin
            Dir.delete(dir) if Dir["#{ dir }/**/*"].empty?
          rescue
            nil
          end
        end
      end

      def find_local_image(filename)
        ext = File.extname(filename)
        filename_with_style = "#{ File.basename(filename, ext) }_original#{ ext }"

        images.each do |image|
          image_filename = File.basename(image)
          if image_filename == filename_with_style || image_filename == File.basename(filename)
            return image if File.exists?(image)
          end
        end
        return nil
      end
    end
  end
end