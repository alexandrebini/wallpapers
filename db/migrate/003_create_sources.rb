class CreateSources < ActiveRecord::Migration
  def up
    create_table :sources, options: 'engine=MyISAM DEFAULT CHARSET=utf8' do |t|
      t.string :name
      t.string :url
      t.text :verification_matcher
    end
    add_index :sources, :name, unique: true
  end

  def down
    drop_table :sources
  end
end