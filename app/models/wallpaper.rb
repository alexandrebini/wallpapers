class Wallpaper < ActiveRecord::Base
  extend FriendlyId

  # attributes
  translates :title, :slug
  friendly_id :title, use: :globalize
  has_attached_file :image,
    path: ':rails_root/public/system/wallpapers/:id/:fingerprint/:basename_:style.:extension',
    url: '/system/wallpapers/:id/:fingerprint/:basename_:style.:extension',
    styles: { }

  attr_accessor :image_url
  attr_accessible :image, :image_url, :source, :tags, :title

  # associations
  has_and_belongs_to_many :colors, join_table: :wallpapers_colors
  has_and_belongs_to_many :tags, join_table: :wallpapers_tags

  # callbacks
  after_create :download_image

  private
  def download_image
    Resque.enqueue(WallpaperDownload, id, image_url) if image_url
  end
end