class Wallpaper < ActiveRecord::Base
  extend FriendlyId

  # attributes
  translates :title, :slug
  friendly_id :title, use: :slugged # :globalize
  has_attached_file :image,
    path: ':rails_root/public/system/wallpapers/:id_partition/:fingerprint/:basename_:style.:extension',
    url: '/system/wallpapers/:id_partition/:fingerprint/:basename_:style.:extension',
    styles: { thumb: '400x300#' }

  # associations
  belongs_to :source
  has_and_belongs_to_many :colors, join_table: :wallpapers_colors
  has_and_belongs_to_many :tags, join_table: :wallpapers_tags

  # callbacks
  after_create :download_image
  after_save :analyse_colors

  # scopes
  scope :random, -> { order('RAND()') }
  scope :downloading, -> { where(status: 'downloading') }
  scope :downloaded, -> { where(status: 'downloaded') }
  scope :pending, -> { where(status: 'pending') }
  scope :recent, -> { order('wallpapers.created_at DESC') }
  scope :highlight, -> { order('wallpapers.views DESC') }

  # validations
  validates :source_url, uniqueness: true, presence: true

  def download_image
    self.status = 'downloading'
    self.save(validate: false)
    worker.perform_async(id) if image_src
  end

  def downloading?
    status == 'downloading'
  end

  def pending?
    status == 'pending'
  end

  private
  def worker
    Crawler.const_get("#{ source.name.downcase.titleize }::Worker")
  end

  def analyse_colors
    reload

    return unless image.present? && File.exists?(image.path)
    Miro::DominantColors.new(image.path).to_hex.each do |hex|
      begin
        color = Color.where(hex: hex).lock(true).first_or_create
      rescue ActiveRecord::RecordNotUnique
        retry
      end
      colors << color unless colors.exists?(color)
    end
  end
end