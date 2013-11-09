class CreateColors < ActiveRecord::Migration
  def up
    create_table :colors, options: 'engine=MyISAM DEFAULT CHARSET=utf8' do |t|
      t.string :hex
    end
    add_index :colors, :hex, unique: true
  end

  def down
    drop_table :colors
  end
end