class Users < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :name, :null => false
      t.boolean :white_label, :default => false, :null => false
      t.string :logo
      t.string :logo_mini
      t.boolean :no_logo, :default => false, :null => false
      t.string :css_file
      t.string :js_file
    end
  end

  def self.down
    drop_table :users
  end
end