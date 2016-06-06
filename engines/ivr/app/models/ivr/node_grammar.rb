module Ivr
  class NodeGrammar < ActiveRecord::Base
    self.table_name = 'ivr.nodes_grammars'

    belongs_to :node, :class_name => 'Ivr::Node', :foreign_key => 'ivr_nodes_id'
    belongs_to :grammar, :class_name => 'Libs::Grammar', :foreign_key => 'libs_grammars_id'
  end
end