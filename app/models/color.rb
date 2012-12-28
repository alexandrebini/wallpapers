class Color < ActiveRecord::Base
  # associations
  has_and_belongs_to_many :wallpapers, join_table: :wallpapers_colors
end