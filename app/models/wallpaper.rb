class Wallpaper < ActiveRecord::Base
  extend FriendlyId

  translates :title, :slug
  friendly_id :title, use: :globalize

  # associations
  has_and_belongs_to_many :colors
  has_and_belongs_to_many :tags
end