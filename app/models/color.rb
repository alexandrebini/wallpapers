class Color < ActiveRecord::Base
  # associations
  has_and_belongs_to_many :wallpapers
end