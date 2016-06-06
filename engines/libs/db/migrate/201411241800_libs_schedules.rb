class LibsSchedules < ActiveRecord::Migration
  def self.up
    create_table 'libs.schedules' do |t|
      t.string :name, :limit => 50, :null => false
      t.string :product
      t.integer :users_id
    end

    create_table 'libs.time_slots' do |t|
      t.integer :order, :null => false, :default => 0
      t.string :day, :limit => 1, :null => false
      t.string :start, :null => false, :default => '00:00', :limit => 5
      t.string :end, :null => false, :default => '23:59', :limit => 5
      t.references :libs_schedules
    end

    create_table 'libs.holidays' do |t|
      t.date :day
      t.references :libs_schedules
    end
  end

  def self.down
    drop_table 'libs.schedules'
    drop_table 'libs.time_slots'
    drop_table 'libs.holidays'
  end
end