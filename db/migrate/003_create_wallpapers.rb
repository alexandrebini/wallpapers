class CreateWallpapers < ActiveRecord::Migration
  def up
    create_table :wallpapers do |t|
      t.string :source
      t.string :slug
      t.attachment :image
      t.text :image_meta
      t.string :image_fingerprint
      t.timestamps
    end
    add_index :wallpapers, :slug
    add_index :wallpapers, :created_at
    Wallpaper.create_translation_table! title: :string, slug: :string
  end

  def down
    drop_table :wallpapers
    Wallpaper.drop_translation_table!
  end
end
