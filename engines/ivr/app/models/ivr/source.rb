module Ivr
  class Source < ActiveRecord::Base
    self.table_name = 'ivr.sources'

    belongs_to :node, :class_name => 'Ivr::SourceConditionNode', :foreign_key => 'ivr_source_condition_nodes_id'

    validates_presence_of :mode, :phone_number
    validates_numericality_of :phone_number
    validates_uniqueness_of :phone_number, :scope => :ivr_source_condition_nodes_id
  end
end