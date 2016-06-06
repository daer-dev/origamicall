module Ivr
  class JumpNode < ActiveRecord::Base
    self.table_name = 'ivr.jump_nodes'

    has_one :option, :class_name => 'Ivr::Option', :foreign_key => 'ivr_nodes_id', :dependent => :destroy
    has_many :simple_children, :class_name => 'Ivr::Node', :foreign_key => 'parent_id'

    attr_accessor :main_node, :children, :dummy, :ivr_nodes_name

    validates_presence_of :name, :ivr_nodes_id
    validates_length_of :name, :maximum => 50, :allow_blank => true

    protected

      after_find do
        # Buscamos el nombre del nodo enlazado (capturando la excepción por si hubiese sido eliminado)
        begin
          jump_node = Ivr::Node.find(self.ivr_nodes_id) unless self.ivr_nodes_id.blank?
          self.ivr_nodes_name = jump_node.name unless jump_node.blank?
        rescue
        end
      end

      after_destroy do
        Ivr::Node.delete_children self
      end

    private

      before_validation do
        # No se puede seleccionar este mismo nodo como destinatario del salto (para evitar que el sistema entre en bucle)
        errors[:ivr_nodes_name].push(I18n.t('ivr.nodes.jump.error_messages.ivr_nodes_name')) if [ self.id, self.parent_id ].include? self.ivr_nodes_id
      end
  end
end