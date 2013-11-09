class CreateTags < ActiveRecord::Migration
  def up
    create_table :tags do |t|
      t.timestamps
      t.string :slug
    end
    add_index :tags, :slug
    Tag.create_translation_table! name: :string, slug: :string
  end

  def down
    drop_table :tags
    Tag.drop_translation_table!
  end
end