class CreateWallpapersTags < ActiveRecord::Migration
  def up
    create_table :wallpapers_tags, id: false, options: 'engine=MyISAM DEFAULT CHARSET=utf8' do |t|
      t.references :wallpaper
      t.references :tag
    end
    add_index :wallpapers_tags, :wallpaper_id
    add_index :wallpapers_tags, :tag_id
    add_index :wallpapers_tags, [:wallpaper_id, :tag_id]
  end

  def down
    drop_table :wallpapers_tags
  end
end