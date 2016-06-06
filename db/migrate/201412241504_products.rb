class Products < ActiveRecord::Migration
  def self.up
    create_table :products do |t|
      t.string :name, :null => false
    end

    create_table :users_products do |t|
      t.references :users, :null => false
      t.references :products, :null => false
    end
  end

  def self.down
    drop_table :users_products
    drop_table :products
  end
end