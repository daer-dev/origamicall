module Ivr
  class IntegrationNode < ActiveRecord::Base
    self.table_name = 'ivr.integration_nodes'

    # Evitamos que Rails utilice "type" como columna de herencia
    self.inheritance_column = nil

    has_one :option, :class_name => 'Ivr::Option', :foreign_key => 'ivr_nodes_id', :dependent => :destroy
    has_many :simple_children, :class_name => 'Ivr::Node', :foreign_key => 'parent_id'

    attr_accessor :main_node, :children, :dummy

    validates_presence_of :name
    validates_length_of :name, :maximum => 50, :allow_blank => true
    validates_presence_of :type
    validates_presence_of :content, :if => :validates_content
    validates_presence_of :url, :unless => :validates_content
    validates :url, url: true, :unless => :validates_content

    protected

      after_initialize do
        # Si se va a crear un nodo vacío, le asignamos un valor a todas las columnas marcadas como "NOT NULL"
        self.content = String.new if self.dummy
      end

      after_create do
        Ivr::Node.allocate_children self
      end

      # Validamos el código PHP con ayuda del sistema
      def code_validation
        begin
          vars_url_params = {
            :code => self.content
          }
          get_url_response IVR_CONFIG['nodes']['integration']['code_system_url'][Rails.env], vars_url_params, :post
        rescue
          true
        end
      end

      after_destroy do
        Ivr::Node.delete_children self
      end

    private

      def validates_content
        self.type == 'content'
      end

      before_validation do
        errors[:content].push(I18n.t('ivr.nodes.integration.error_messages.code_syntax')) if self.type == 'content' && not self.content.blank? && not self.code_validation
      end
  end
end
