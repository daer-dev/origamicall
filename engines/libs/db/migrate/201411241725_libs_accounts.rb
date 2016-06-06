class LibsAccounts < ActiveRecord::Migration
  def self.up
    execute 'CREATE SCHEMA libs'

    create_table 'libs.accounts' do |t|
      t.string :name, :limit => 50, :null => false
      t.string :type, :limit => 20, :null => false
      t.string :server, :limit => 255
      t.integer :port
      t.string :user
      t.string :password
      t.string :folder, :limit => 255
      t.string :email
      t.string :url, :limit => 255
      t.string :product
      t.integer :users_id, :null => false
    end
  end

  def self.down
    drop_table 'libs.accounts'
    execute 'DROP SCHEMA libs'
  end
end