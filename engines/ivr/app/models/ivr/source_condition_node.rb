module Ivr
  class SourceConditionNode < ActiveRecord::Base
    self.table_name = 'ivr.source_condition_nodes'

    has_one :option, :class_name => 'Ivr::Option', :foreign_key => 'ivr_nodes_id', :dependent => :destroy
    has_many :sources, :class_name => 'Ivr::Source', :foreign_key => 'ivr_source_condition_nodes_id', :dependent => :destroy
    has_many :simple_children, :class_name => 'Ivr::Node', :foreign_key => 'parent_id'

    attr_accessor :main_node, :children, :dummy, :ok_node, :error_node, :related_sources

    validates_presence_of :name
    validates_length_of :name, :maximum => 50, :allow_blank => true

    protected

      after_initialize do
        # Orígenes
        self.related_sources ||= { 's_0' => { 'mode' => String.new, 'phone_number' => String.new } }
      end

      after_create do
        Ivr::Node.dummies_and_allocation self
      end

      after_find do
        # Orígenes
        self.related_sources = Hash.new
        self.sources.each{ |x| self.related_sources["s_#{x.id}"] = x.attributes } unless self.sources.blank?
        self.related_sources['s_0'] = { 'mode' => String.new, 'phone_number' => String.new }
      end

      after_save do
        # Orígenes
        self.sources.destroy_all
        unless self.related_sources.blank?
          self.related_sources.each do |k,v|
            unless v['phone_number'].blank?
              new_s = Ivr::Source.new({
                :mode => v['mode'],
                :phone_number => v['phone_number'],
                :ivr_source_condition_nodes_id => self.id
              })
              new_s.save if new_s.valid?
            end
          end
        end
      end

      after_update do
        Ivr::Node.dummies_and_allocation self, false
      end

      after_destroy do
        Ivr::Node.delete_children self
      end

    private

      before_validation do
        # Un nodo de este tipo, como es lógico, siempre debe tener orígenes asociados
        errors[:base].push(I18n.t('ivr.nodes.source_condition.error_messages.sources')) if not self.related_sources.blank? && self.related_sources.values.delete_if{ |x| x['phone_number'].blank? }.blank?
      end
  end
end
