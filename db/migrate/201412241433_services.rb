class Services < ActiveRecord::Migration
  def self.up
    create_table :services do |t|
      t.string :number, :null => false
    end

    create_table :users_services do |t|
      t.references :users, :null => false
      t.references :services, :null => false
    end
  end

  def self.down
    drop_table :users_services
    drop_table :services
  end
end