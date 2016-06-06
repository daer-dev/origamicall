module Ivr
  class NodeTable < ActiveRecord::Base
    self.table_name = 'ivr.nodes_tables'

    belongs_to :node, :class_name => 'Ivr::MainNode', :foreign_key => 'ivr_nodes_id'
    belongs_to :table, :class_name => 'Libs::Table', :foreign_key => 'libs_tables_id'
  end
end