module Crawler
  module FileHelper
    class << self
      def images(options={})
        default_options = { dir: "#{ Rails.root }/public/system/wallpapers*" }
        options = default_options.merge(options)

        if options[:cache]
          @images ||= Dir["#{ options[:dir] }/**/*"].reject { |fn| File.directory?(fn) }
        else
          Dir["#{ options[:dir] }/**/*"].reject { |fn| File.directory?(fn) }
        end
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

      def find_local_image(filename, options={})
        ext = File.extname(filename)
        filename_with_style = "#{ File.basename(filename, ext) }_original#{ ext }"

        Crawler::FileHelper.images(options).find do |path|
          path.index(filename_with_style) || path.index(filename) && File.exists?(path)
        end
      end

      def valid_image?(path, options={})
        grays = %w(#808080 #868584 #939294 #79776d #838183 #818181 #848384 #828281
          #888f94 #848688 #838892 #818080 #7b7f78)

        return false if options[:min_size] && File.size(path) < options[:min_size]

        colors = Miro::DominantColors.new(path)
        if grays.include?(colors.to_hex.first) && colors.by_percentage.first * 100 > 60
          return false
        else
          return true
        end
      rescue
        return false
      end
    end
  end
end