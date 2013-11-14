class Source < ActiveRecord::Base
  # associations
  has_many :wallpapers

  def slug
    name.downcase
  end
end