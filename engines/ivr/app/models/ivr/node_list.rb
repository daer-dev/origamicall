module Ivr
  class NodeList < ActiveRecord::Base
    self.table_name = 'ivr.nodes_lists'

    belongs_to :nodes, :class_name => 'Ivr::Node', :foreign_key => 'ivr_nodes_id'
    belongs_to :lists, :class_name => 'Libs::List', :foreign_key => 'libs_lists_id'
  end
end