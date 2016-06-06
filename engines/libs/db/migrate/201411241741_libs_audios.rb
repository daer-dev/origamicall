class LibsAudios < ActiveRecord::Migration
	def self.up
    create_table 'libs.audios' do |t|
			t.string :name, :limit => 50, :null => false
			t.attachment :att
			t.string :product
			t.integer :users_id, :null => false
		end
	end

	def self.down
		drop_table 'libs.audios'
	end
end