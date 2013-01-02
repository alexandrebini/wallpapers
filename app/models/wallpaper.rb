class Wallpaper < ActiveRecord::Base
  extend FriendlyId

  # attributes
  translates :title, :slug
  friendly_id :title, use: :globalize
  has_attached_file :image,
    path: ':rails_root/public/system/wallpapers/:id/:fingerprint/:basename_:style.:extension',
    url: '/system/wallpapers/:id/:fingerprint/:basename_:style.:extension',
    styles: { }

  attr_accessible :image, :image_src, :source, :source_url, :tags, :title

  # associations
  belongs_to :source
  has_and_belongs_to_many :colors, join_table: :wallpapers_colors
  has_and_belongs_to_many :tags, join_table: :wallpapers_tags

  # callbacks
  after_create :download_image
  after_save :analyse_colors

  private
  def download_image
    Resque.enqueue(WallpaperDownload, id) if image_src
  end

  def analyse_colors
    reload

    return unless image.present? && File.exists?(image.path)
    Miro::DominantColors.new(image.path).to_hex.each do |hex|
      color = Color.find_or_create_by_hex(hex)
      colors << color unless colors.exists?(color)
    end
  end
end