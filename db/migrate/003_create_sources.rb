class CreateSources < ActiveRecord::Migration
  def up
    create_table :sources do |t|
      t.string :name
      t.string :url
    end
    add_index :sources, :name
  end

  def down
    drop_table :sources
  end
end
