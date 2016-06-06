class LibsTables < ActiveRecord::Migration
  def self.up
    create_table 'libs.tables' do |t|
      t.string :name, :limit => 50, :null => false
      t.string :product
      t.integer :users_id
    end

    create_table 'libs.rows' do |t|
      t.string :name, :limit => 50, :null => false
      t.text :value
      t.references :libs_tables
    end

    execute '
      ALTER TABLE libs.rows
        ADD CONSTRAINT libs_tables_id
        FOREIGN KEY(libs_tables_id)
        REFERENCES libs.tables(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE'
  end

  def self.down
    drop_table 'libs.rows'
    drop_table 'libs.tables'
  end
end