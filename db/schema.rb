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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 6) do

  create_table "colors", force: true do |t|
    t.string "hex"
  end

  add_index "colors", ["hex"], name: "index_colors_on_hex", unique: true, using: :btree

  create_table "sources", force: true do |t|
    t.string "name"
    t.string "url"
    t.text   "verification_matcher"
  end

  add_index "sources", ["name"], name: "index_sources_on_name", unique: true, using: :btree

  create_table "tag_translations", force: true do |t|
    t.integer  "tag_id",     null: false
    t.string   "locale",     null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.string   "slug"
  end

  add_index "tag_translations", ["locale"], name: "index_tag_translations_on_locale", using: :btree
  add_index "tag_translations", ["tag_id"], name: "index_tag_translations_on_tag_id", using: :btree

  create_table "tags", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.string   "slug"
  end

  add_index "tags", ["name"], name: "index_tags_on_name", unique: true, using: :btree
  add_index "tags", ["slug"], name: "index_tags_on_slug", unique: true, using: :btree

  create_table "wallpaper_translations", force: true do |t|
    t.integer  "wallpaper_id", null: false
    t.string   "locale",       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title"
    t.string   "slug"
  end

  add_index "wallpaper_translations", ["locale"], name: "index_wallpaper_translations_on_locale", using: :btree
  add_index "wallpaper_translations", ["wallpaper_id"], name: "index_wallpaper_translations_on_wallpaper_id", using: :btree

  create_table "wallpapers", force: true do |t|
    t.integer  "source_id"
    t.string   "source_url"
    t.string   "title"
    t.string   "slug"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.string   "image_src"
    t.text     "image_meta"
    t.string   "image_fingerprint"
    t.string   "status"
    t.integer  "views"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "wallpapers", ["created_at"], name: "index_wallpapers_on_created_at", using: :btree
  add_index "wallpapers", ["image_file_name"], name: "index_wallpapers_on_image_file_name", using: :btree
  add_index "wallpapers", ["image_src"], name: "index_wallpapers_on_image_src", unique: true, using: :btree
  add_index "wallpapers", ["slug"], name: "index_wallpapers_on_slug", using: :btree
  add_index "wallpapers", ["source_id"], name: "index_wallpapers_on_source_id", using: :btree
  add_index "wallpapers", ["source_url"], name: "index_wallpapers_on_source_url", unique: true, using: :btree
  add_index "wallpapers", ["status"], name: "index_wallpapers_on_status", using: :btree
  add_index "wallpapers", ["views"], name: "index_wallpapers_on_views", using: :btree

  create_table "wallpapers_colors", id: false, force: true do |t|
    t.integer "wallpaper_id"
    t.integer "color_id"
  end

  add_index "wallpapers_colors", ["color_id"], name: "index_wallpapers_colors_on_color_id", using: :btree
  add_index "wallpapers_colors", ["wallpaper_id", "color_id"], name: "index_wallpapers_colors_on_wallpaper_id_and_color_id", using: :btree
  add_index "wallpapers_colors", ["wallpaper_id"], name: "index_wallpapers_colors_on_wallpaper_id", using: :btree

  create_table "wallpapers_tags", id: false, force: true do |t|
    t.integer "wallpaper_id"
    t.integer "tag_id"
  end

  add_index "wallpapers_tags", ["tag_id"], name: "index_wallpapers_tags_on_tag_id", using: :btree
  add_index "wallpapers_tags", ["wallpaper_id", "tag_id"], name: "index_wallpapers_tags_on_wallpaper_id_and_tag_id", using: :btree
  add_index "wallpapers_tags", ["wallpaper_id"], name: "index_wallpapers_tags_on_wallpaper_id", using: :btree

end
