class AddViewsToWallpapers < ActiveRecord::Migration
  def change
    add_column :wallpapers, :views, :integer
    add_index :wallpapers, :views
  end
end