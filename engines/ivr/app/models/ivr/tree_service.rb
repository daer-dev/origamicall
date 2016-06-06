module Ivr
  class TreeService < ActiveRecord::Base
    self.table_name = 'ivr.trees_services'

    belongs_to :tree, :class_name => 'Ivr::Tree', :foreign_key => 'ivr_trees_id'
    belongs_to :service, :class_name => 'Service', :foreign_key => 'services_id'
  end
end