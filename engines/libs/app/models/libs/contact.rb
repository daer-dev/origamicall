module Libs
  class Contact < ActiveRecord::Base
    self.table_name = 'libs.contacts'

    belongs_to :list, :class_name => 'Libs::List', :foreign_key => 'libs_lists_id'

    validates_numericality_of :phone_number
  end
end