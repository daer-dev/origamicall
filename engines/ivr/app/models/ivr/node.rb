module Ivr
  class Node < ActiveRecord::Base
    self.table_name = 'ivr.nodes_web_view'
    self.primary_key = 'id'

    # Evitamos que Rails utilice "type" como columna de herencia
    self.inheritance_column = nil

    belongs_to :parent, :class_name => 'Ivr::Node', :foreign_key => 'parent_id'
    has_many :children, :class_name => 'Ivr::Node', :foreign_key => 'parent_id'

    attr_accessor :data, :real_type

    # Formateamos los datos de forma que los pueda entender el SpaceTree (la librería JS que dibuja el árbol)
    def get_array_data
      # Capturamos la excepción y devolvemos un array vacío si no disponemos del modelo necesario
      begin
        # Montamos el hash de atributos omitiendo los que tienen valores nulos o vacíos
        data_attrs = self.data.attributes.merge!({
          :type => self.real_type
        }).delete_if{ |k,v| %w(id name main_node).include? k.to_s || v.nil? }
        # Añadimos los campos "dtmf" y "asr"
        data_attrs['dtmf_value'] = self.dtmf unless self.dtmf.blank?
        data_attrs['asr_value'] = self.asr unless self.asr.blank?
        # Devolvemos el resultado
        data = [{
          :id => self.id,
          :name => self.name,
          :data => data_attrs,
          :children => self.get_children
        }]
        data
      rescue
        data = Array.new
      end
    end

    protected

      after_initialize do
        add_data
      end

      after_find do
        add_data
        self.real_type = self.get_type
      end

      # Averiguamos el tipo del nodo, quitándole el sufijo al que obtenemos de la BBDD
      def get_type
        if self.attributes.include? 'type'
          self_type = self.type.include?('.') ? self.type.split('.')[1] : self.type
          type = self_type.gsub("_#{IVR_CONFIG['node_tables_sufix']}", String.new)
        else
          type = self.class.to_s.tableize.singularize.gsub("_#{IVR_CONFIG['node_tables_sufix'].singularize}", String.new)
        end
        type
      end

      # Sacamos el listado de nodos que cuelgan del que estamos tratando
      def get_children
        children = Array.new
        Ivr::Node.where('path ~ ?', "#{self.path}.*{1}").to_a.each do |node|
          children += node.get_array_data
        end
        children
      end

      def add_data
        unless self.type.blank?
          # Agregamos el atributo "data", que contiene todo lo específico del nodo según su tipo
          node_class = "Ivr::#{self.get_type.camelize}Node".constantize
          if self.id.blank?
            self.data = node_class.new
          else
            self.data = node_class.where(id: self.id).first
          end
          # Le metemos también los datos de su nodo principal asociado
          main_node = Ivr::MainNode.where(id: self.path.split('.')[0]).to_a
          self.data.main_node = main_node[0] unless main_node.blank? || self.data.class.to_s == 'Ivr::MainNode'
        end
      end

      # Insertamos un nodo con datos ficticios, el cual tendrá que editar el usuario más adelante
      def self.create_dummy_node(parent, type, status = nil)
        # Definimos los atributos que tendrá el nuevo nodo
        attrs = {
          :name => I18n.t('ivr.nodes.unconfigured'),
          :parent_id => parent.id,
          :status => status,
          :dummy => true
        }
        # Si es de tipo "Entrada de datos", le asignamos la primera variable que haya creada
        attrs[:ivr_variables_id] = parent.main_node.vars[0].id if type == 'data_entry'
        # Lo creamos
        obj = "Ivr::#{(type + '_' + IVR_CONFIG['node_tables_sufix'].singularize).camelize}".constantize.new attrs
        obj.save validate: false
        obj
      end

      # Reasignación de hijos
      def self.allocate_children(node, defined_parent = nil)
        # A menos que el nodo esté sin configurar, en cuyo caso lo indicamos mediante el atributo "dummy", seguimos con el proceso
        unless node.dummy
          new_parent = defined_parent.blank? ? node.id : defined_parent
          # Ejecutamos el update
          Ivr::Node.where('parent_id = ? AND id != ?', node.parent_id, node.id).update_all(parent_id: new_parent)
        end
      end

      # Creación de estados y reasignación de nodos (función que engloba las dos anteriores)
      def self.dummies_and_allocation(node, allocation = true)
        ok_node = Ivr::Node.create_dummy_node node, node.ok_node, true unless node.ok_node.blank?
        Ivr::Node.create_dummy_node node, node.error_node, false unless node.error_node.blank?
        Ivr::Node.allocate_children node, ok_node.id unless node.dummy || ok_node.blank? || not allocation
      end

      # Eliminación de hijos
      def self.delete_children(node)
        Ivr::Node.destroy_all [ 'path <@ ?', node.path ]
      end
  end
end
