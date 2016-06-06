module Ivr
  class MainNode < ActiveRecord::Base
    self.table_name = 'ivr.main_nodes'
    self.primary_key = 'id'

    has_one :tree, :class_name => 'Ivr::Tree', :foreign_key => 'ivr_main_nodes_id'
    has_many :vars, :class_name => 'Ivr::Variable', :foreign_key => 'ivr_nodes_id'
    has_many :nodes_tables, :class_name => 'Ivr::NodeTable', :foreign_key => 'ivr_nodes_id'
    has_many :tables, :through => :nodes_tables
    has_many :nodes_lists, :class_name => 'Ivr::NodeList', :foreign_key => 'ivr_nodes_id'
    has_many :lists, :through => :nodes_lists
    has_many :simple_children, :class_name => 'Ivr::Node', :foreign_key => 'parent_id'

    attr_accessor :main_node, :children, :related_vars, :related_tables, :related_lists

    validates_presence_of :name
    validates_length_of :name, :maximum => 50, :allow_blank => true

    protected

      after_initialize do
        # Variables
        self.related_vars ||= { 'v_0' => { 'name' => String.new, 'value' => String.new, 'type' => String.new } }
      end

      after_find do
        # Variables
        self.related_vars = Hash.new
        self.vars.each{ |x| self.related_vars["v_#{x.id}"] = x.attributes } unless self.vars.blank?
        self.related_vars['v_0'] = { 'name' => String.new, 'value' => String.new, 'type' => String.new }
      end

      before_save do
        # Si no se ha seleccionado ninguna lista, tampoco guardamos el tipo
        self.lists_type = String.new if self.related_lists.blank? || self.related_lists["group_#{self.lists_type}"].blank?
      end

      after_save do
        # VARIABLES
        # Creamos un array que almacene todas las que vamos agregando
        current_vars = Array.new
        # Recorremos el listado
        self.related_vars.each do |k,v|
          var_id = k.split('_')[1]
          new_var = Ivr::Variable.new({
            :name => v['name'],
            :value => v['value'],
            :type => v['type'],
            :ivr_nodes_id => self.id
          })
          var = self.vars.select{ |x| x.id.to_s == var_id }
          unless var.blank?
            current_vars.push var_id.to_i
            # Si la variable ya existía y ha sido modificada, actualizamos sus atributos
            if new_var.attributes.except('id') != var[0].attributes.except('id')
              v.each do |kk,vv|
                eval("var[0].#{kk} = vv")
              end
              var[0].save
            end
          else
            # Sino, la creamos (sólo si es válida)
            new_var = Ivr::Variable.new({
              :name => v['name'],
              :value => v['value'],
              :type => v['type'],
              :ivr_nodes_id => self.id
            })
            if new_var.valid?
              new_var.save
              current_vars.push new_var.id
            end
          end
        end unless self.related_vars.blank?
        # Y por último, borramos las que ya no sean necesarias
        self.vars.each{ |x| x.destroy unless current_vars.include? x.id }
        # TABLAS
        self.nodes_tables.destroy_all
        unless self.related_tables.blank? || self.related_tables['group_'].blank?
          self.related_tables['group_'].each do |k,v|
            new_nt = Ivr::NodeTable.new({
              :libs_tables_id => v,
              :ivr_nodes_id => self.id
            })
            new_nt.save
          end
        end
        # LISTAS
        self.nodes_lists.destroy_all
        unless self.related_lists.blank? || self.related_lists["group_#{self.lists_type}"].blank?
          self.related_lists["group_#{self.lists_type}"].each do |k,v|
            new_nl = Ivr::NodeList.new({
              :libs_lists_id => v,
              :ivr_nodes_id => self.id
            })
            new_nl.save
          end
        end
      end

    private

      before_validation do
        # No se permite la eliminación de una variable que se está usando en un nodo "entrada de datos"
        unless self.tree.blank? || self.vars.blank?
          current_vars = self.related_vars.blank? ? Array.new : self.related_vars.map{ |k,v| k.split('_')[1].to_i }
          Ivr::Node.where([ 'path <@ ?', self.path ]).to_a.select{ |n| n.type == 'ivr.data_entry_nodes' }.map{ |x| [ x.name, x.data.ivr_variables_id ] }.each do |x|
            errors[:base].push(I18n.t('ivr.nodes.main.error_messages.data_entry_vars', var: self.vars.select{ |xx| xx.id == x[1] }[0].name, node: x[0])) unless current_vars.include? x[1]
          end
        end
      end
  end
end
