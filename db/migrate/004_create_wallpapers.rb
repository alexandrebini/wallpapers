class CreateWallpapers < ActiveRecord::Migration
  def up
    create_table :wallpapers do |t|
      t.references :source
      t.string :source_url
      t.string :slug
      t.attachment :image
      t.string :image_src
      t.text :image_meta
      t.string :image_fingerprint
      t.string :status
      t.integer :views
      t.timestamps
    end
    add_index :wallpapers, :slug
    add_index :wallpapers, :created_at
    add_index :wallpapers, :image_file_name
    add_index :wallpapers, :source_id
    add_index :wallpapers, :status
    add_index :wallpapers, :views
    Wallpaper.create_translation_table! title: :string, slug: :string
  end

  def down
    drop_table :wallpapers
    Wallpaper.drop_translation_table!
  end
end