class Wallpaper < ActiveRecord::Base
  extend FriendlyId

  # attributes
  translates :title, :slug
  friendly_id :title, use: :globalize
  has_attached_file :image,
    path: '/wallpapers/:fingerprint/:basename_:style.:extension',
    styles: { thumb: '128x128#' },
    storage: :s3,
    s3_credentials: {
      access_key_id: 'AKIAJERSSKD55B24HNYA',
      secret_access_key: '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'
    },
    bucket: 'wallpapersbr'

  attr_accessible :image, :image_src, :image_file_name, :image_content_type,
    :image_file_size, :image_updated_at, :image_meta, :image_fingerprint,
    :status, :source, :source_url, :tags, :title

  # associations
  belongs_to :source
  has_and_belongs_to_many :colors, join_table: :wallpapers_colors
  has_and_belongs_to_many :tags, join_table: :wallpapers_tags

  # callbacks
  after_create :download_image
  after_save :analyse_colors

  # scopes
  scope :random, order: 'RAND()'
  scope :downloading, where(status: 'downloading')
  scope :downloaded, where(status: 'downloaded')
  scope :pending, where(status: 'pending')

  def download_image
    self.status = 'downloading'
    self.save(validate: false)
    Resque.enqueue(WallpaperDownload, id) if image_src
  end

  def downloading?
    status == 'downloading'
  end

  def pending?
    status == 'pending'
  end

  private
  def analyse_colors
    reload

    return unless image.present? && File.exists?(image.path)
    Miro::DominantColors.new(image.path).to_hex.each do |hex|
      color = Color.find_or_create_by_hex(hex)
      colors << color unless colors.exists?(color)
    end
  end
end
