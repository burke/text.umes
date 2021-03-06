class CreateBooks < ActiveRecord::Migration
  def self.up
    create_table :books do |t|
      t.string :title
      t.string :author
      t.string :seller
      t.decimal :price
      t.text :comments
      t.string :isbn
      t.boolean :delta
      t.boolean :confirmed
      t.boolean :disabled
      t.string :salt
      t.timestamps
    end
  end

  def self.down
    drop_table :books
  end
end
