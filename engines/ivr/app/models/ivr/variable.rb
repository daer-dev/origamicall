module Ivr
  class Variable < ActiveRecord::Base
    self.table_name = 'ivr.variables'

    # Evitamos que Rails utilice "type" como columna de herencia
    self.inheritance_column = nil

    belongs_to :node, :class_name => 'Ivr::MainNode', :foreign_key => 'ivr_nodes_id'

    validates_presence_of :name, :value, :type
  end
end