class LibsDestinations < ActiveRecord::Migration
  def self.up
    create_table 'libs.destinations' do |t|
      t.string :name, :limit => 50, :null => false
      t.string :phone_number, :limit => 15, :null => false
      t.string :product
      t.integer :users_id, :null => false
    end
  end

  def self.down
    drop_table 'libs.destinations'
  end
end