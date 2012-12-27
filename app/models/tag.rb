class Tag < ActiveRecord::Base
  extend FriendlyId

  translates :name, :slug
  friendly_id :name, use: :globalize

  # associations
  has_and_belongs_to_many :wallpapers
end