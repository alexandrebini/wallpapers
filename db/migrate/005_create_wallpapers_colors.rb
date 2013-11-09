class CreateWallpapersColors < ActiveRecord::Migration
  def up
    create_table :wallpapers_colors, id: false do |t|
      t.references :wallpaper
      t.references :color
    end
    add_index :wallpapers_colors, :wallpaper_id
    add_index :wallpapers_colors, :color_id
    add_index :wallpapers_colors, [:wallpaper_id, :color_id]
  end

  def down
    drop_table :wallpapers_colors
  end
end