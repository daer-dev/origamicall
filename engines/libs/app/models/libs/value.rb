module Libs
  class Value < ActiveRecord::Base
    self.table_name = 'libs.values'

    belongs_to :option, :class_name => 'Libs::Option', :foreign_key => 'libs_options_id'

    validates_uniqueness_of :name, :scope => :libs_options_id
  end
end