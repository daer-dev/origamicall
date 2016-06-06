module Ivr
  class NodeAccount < ActiveRecord::Base
    self.table_name = 'ivr.nodes_accounts'

    belongs_to :nodes, :class_name => 'Ivr::Node', :foreign_key => 'ivr_nodes_id'
    belongs_to :accounts, :class_name => 'Libs::Account', :foreign_key => 'libs_accounts_id'
  end
end