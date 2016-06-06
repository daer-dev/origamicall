class LibsLists < ActiveRecord::Migration
  def self.up
    create_table 'libs.lists' do |t|
      t.string :name, :limit => 50, :null => false
      t.string :type, :limit => 20, :null => false
      t.attachment :att
      t.string :product
      t.integer :users_id, :null => false
    end

    create_table 'libs.contacts' do |t|
      t.references :libs_lists, :null => false
      t.string :phone_number, :limit => 15, :null => false
    end

    execute '
      ALTER TABLE libs.contacts
        ADD CONSTRAINT libs_lists_id
        FOREIGN KEY(libs_lists_id)
        REFERENCES libs.lists(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE'
  end

  def self.down
    drop_table 'libs.contacts'
    drop_table 'libs.lists'
  end
end