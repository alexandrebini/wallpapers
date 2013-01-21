class WallpaperSerializer < ActiveModel::Serializer
  attributes :id, :source, :source_url, :slug, :status
end
