class LibsGrammars < ActiveRecord::Migration
  def self.up
    create_table 'libs.grammars' do |t|
      t.string :name, :limit => 50, :null => false
      t.string :product
      t.integer :users_id
    end

    create_table 'libs.options' do |t|
      t.string :name, :limit => 100, :null => false
      t.references :libs_grammars, :null => false
    end

    execute '
      ALTER TABLE libs.options
        ADD CONSTRAINT libs_grammars_id
        FOREIGN KEY(libs_grammars_id)
        REFERENCES libs.grammars(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE'

    create_table 'libs.values' do |t|
      t.string :name, :limit => 100, :null => false
      t.references :libs_options, :null => false
    end

    execute '
      ALTER TABLE libs.values
        ADD CONSTRAINT libs_options_id
        FOREIGN KEY(libs_options_id)
        REFERENCES libs.options(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE'
  end

  def self.down
    drop_table 'libs.values'
    drop_table 'libs.options'
    drop_table 'libs.grammars'
  end
end