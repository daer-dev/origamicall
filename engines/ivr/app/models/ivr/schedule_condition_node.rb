module Ivr
  class ScheduleConditionNode < ActiveRecord::Base
    self.table_name = 'ivr.schedule_condition_nodes'

    has_one :option, :class_name => 'Ivr::Option', :foreign_key => 'ivr_nodes_id', :dependent => :destroy
    belongs_to :schedule, :class_name => 'Libs::Schedule', :foreign_key => 'libs_schedules_id'
    has_many :simple_children, :class_name => 'Ivr::Node', :foreign_key => 'parent_id'

    attr_accessor :main_node, :children, :dummy, :ok_node, :error_node

    validates_presence_of :name, :libs_schedules_id
    validates_length_of :name, :maximum => 50, :allow_blank => true

    protected

      after_create do
        Ivr::Node.dummies_and_allocation self
      end

      after_update do
        Ivr::Node.dummies_and_allocation self, false
      end

      after_destroy do
        Ivr::Node.delete_children self
      end
  end
end