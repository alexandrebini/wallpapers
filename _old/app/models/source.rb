class Source < ActiveRecord::Base
  # associations
  has_many :wallpapers

  # attributes
  attr_accessible :name, :url
end