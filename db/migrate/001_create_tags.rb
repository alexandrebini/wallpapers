class CreateTags < ActiveRecord::Migration
  def up
    create_table :tags, options: 'engine=MyISAM DEFAULT CHARSET=utf8' do |t|
      t.timestamps
      t.string :name
      t.string :slug
    end
    add_index :tags, :name, unique: true
    add_index :tags, :slug, unique: true
    Tag.create_translation_table! name: :string, slug: :string
  end

  def down
    drop_table :tags
    Tag.drop_translation_table!
  end
end