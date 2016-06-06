module Libs
  class Row < ActiveRecord::Base
    self.table_name = 'libs.rows'

    belongs_to :table, :class_name => 'Libs::Table', :foreign_key => 'libs_tables_id'

    validates_presence_of :name, :value
  end
end