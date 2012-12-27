class CreateWallpapers < ActiveRecord::Migration
  def up
    create_table :wallpapers do |t|
      t.string :source
      t.timestamps
    end
    Wallpaper.create_translation_table! title: :string, slug: :string
  end

  def down
    drop_table :wallpapers
    Wallpaper.drop_translation_table!
  end
end
