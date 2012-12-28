# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 5) do

  create_table "colors", :force => true do |t|
    t.string "hex"
  end

  add_index "colors", ["hex"], :name => "index_colors_on_hex"

  create_table "tag_translations", :force => true do |t|
    t.integer  "tag_id"
    t.string   "locale"
    t.string   "name"
    t.string   "slug"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "tag_translations", ["locale"], :name => "index_tag_translations_on_locale"
  add_index "tag_translations", ["tag_id"], :name => "index_tag_translations_on_tag_id"

  create_table "tags", :force => true do |t|
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "slug"
  end

  add_index "tags", ["slug"], :name => "index_tags_on_slug"

  create_table "wallpaper_translations", :force => true do |t|
    t.integer  "wallpaper_id"
    t.string   "locale"
    t.string   "title"
    t.string   "slug"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "wallpaper_translations", ["locale"], :name => "index_wallpaper_translations_on_locale"
  add_index "wallpaper_translations", ["wallpaper_id"], :name => "index_wallpaper_translations_on_wallpaper_id"

  create_table "wallpapers", :force => true do |t|
    t.string   "source"
    t.string   "slug"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.string   "image_fingerprint"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  add_index "wallpapers", ["created_at"], :name => "index_wallpapers_on_created_at"
  add_index "wallpapers", ["slug"], :name => "index_wallpapers_on_slug"

  create_table "wallpapers_colors", :id => false, :force => true do |t|
    t.integer "wallpaper_id"
    t.integer "color_id"
  end

  add_index "wallpapers_colors", ["color_id"], :name => "index_wallpapers_colors_on_color_id"
  add_index "wallpapers_colors", ["wallpaper_id", "color_id"], :name => "index_wallpapers_colors_on_wallpaper_id_and_color_id"
  add_index "wallpapers_colors", ["wallpaper_id"], :name => "index_wallpapers_colors_on_wallpaper_id"

  create_table "wallpapers_tags", :id => false, :force => true do |t|
    t.integer "wallpaper_id"
    t.integer "tag_id"
  end

  add_index "wallpapers_tags", ["tag_id"], :name => "index_wallpapers_tags_on_tag_id"
  add_index "wallpapers_tags", ["wallpaper_id", "tag_id"], :name => "index_wallpapers_tags_on_wallpaper_id_and_tag_id"
  add_index "wallpapers_tags", ["wallpaper_id"], :name => "index_wallpapers_tags_on_wallpaper_id"

end
