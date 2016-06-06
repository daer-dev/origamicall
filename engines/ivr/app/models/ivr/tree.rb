module Ivr
  class Tree < ActiveRecord::Base
    self.table_name = 'ivr.trees'

    # TODO: Comprobar si es threadsafe
    # Métodos de clase
    class << self
      # Evitamos llamar al callback "after_find" en los listados
      attr_accessor :callback_after_find
    end
    self.callback_after_find = true

    has_many :trees_services, :class_name => 'Ivr::TreeService', :foreign_key => 'ivr_trees_id', :dependent => :destroy
    has_many :services, :through => :trees_services
    belongs_to :main_node, :class_name => 'Ivr::MainNode', :foreign_key => 'ivr_main_nodes_id', :dependent => :destroy

    attr_accessor :nodes, :related_services

    validates_presence_of :name
    validates_uniqueness_of :name, :scope => :users_id

    protected

      before_save do
        # Creamos el nodo principal, que es el que aparece siempre por defecto
        if self.main_node.blank?
          main_node = Ivr::MainNode.new({
            :name => I18n.t('ivr.nodes.main.name')
          })
          main_node.save

          self.ivr_main_nodes_id = main_node.id
        end
      end

      after_save do
        # Borramos todas las asociaciones con servicios que hubiese anteriormente
        self.trees_services.destroy_all
        unless self.related_services.blank?
          self.related_services.each do |k,v|
            # Desasociamos los servicios también de otras CV que pudiesen tener
            Ivr::TreeService.delete_all :services_id => v
            # Vinculamos la tree a los servicios que se hayan seleccionado
            Ivr::TreeService.new({
              :services_id => v,
              :ivr_trees_id => self.id
            }).save
          end
        end
      end

      after_find do
        if Ivr::Tree.callback_after_find
          # Agregamos el listado de nodos en el formato correcto, con todos sus hijos anidados
          self.nodes = Ivr::Node.find(self.ivr_main_nodes_id).get_array_data[0] unless self.main_node.blank?
        end
      end
  end
end