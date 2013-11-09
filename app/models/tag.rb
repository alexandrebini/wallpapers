class Tag < ActiveRecord::Base
  extend FriendlyId

  translates :name, :slug
  friendly_id :name, use: :slugged# :globalize

  # associations
  has_and_belongs_to_many :wallpapers, join_table: :wallpapers_tags

  # validations
  validates :name, uniqueness: true, presence: true
  validates :slug, uniqueness: true, presence: true
end