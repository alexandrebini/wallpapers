class CreateColors < ActiveRecord::Migration
  def up
    create_table :colors do |t|
      t.string :hex
    end
    add_index :colors, :hex
  end

  def down
    drop_table :colors
  end
end
