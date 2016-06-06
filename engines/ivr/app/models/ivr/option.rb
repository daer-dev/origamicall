module Ivr
  class Option < ActiveRecord::Base
    self.table_name = 'ivr.options'

    belongs_to :menu_node, :class_name => 'Ivr::MenuNode', :foreign_key => 'ivr_menu_nodes_id'
    belongs_to :node, :class_name => 'Ivr::Node', :foreign_key => 'ivr_nodes_id'

    validates_presence_of :dtmf, :if => :validates_dtmf
    validates_uniqueness_of :dtmf, :scope => :ivr_menu_nodes_id
    validates_presence_of :libs_options_id, :if => :validates_grammar_option
    validates_uniqueness_of :libs_options_id, :scope => :ivr_menu_nodes_id
    validates_uniqueness_of :default, :scope => :ivr_menu_nodes_id, :if => :validates_default

    def dtmf_values
      dtmf_values = Array.new
      # Expandimos los rangos
      values = self.dtmf.split('-')
      if values.length > 1
        values.last.to_i.downto(values.first.to_i) { |n| dtmf_values.push n.to_s }
      else
        # Convertimos en un array las opciones separadas por comas
        values = self.dtmf.split(',')
        if values.length > 1
          dtmf_values = values
        else
          dtmf_values.push self.dtmf
        end
      end
      dtmf_values
    end

    private

      # Se debe rellenar al menos uno de los dos campos (opción de la gramática asociada o DTMF)
      def validates_dtmf
        self.libs_options_id.blank? && not self.default
      end

      # Idem
      def validates_grammar_option
        self.dtmf.blank? && not self.default
      end

      # Sólo se valida la existencia de un valor si este es "true"
      def validates_default
        self.default
      end

      before_validation do
        # Validamos DTMF, rangos, valores separados por comas y duplicados
        result = true
        # Rangos
        values = self.dtmf.split('-')
        if values.length > 2
          errors[:option].push(I18n.t('ivr.nodes.menu.error_messages.options_incorrect_range_format', :value => self.dtmf.dump))
          result = false
        end
        if values.length > 1
          values.each do |v|
            if v.match(/^[0-9]+$/) == nil
              errors[:option].push(I18n.t('ivr.nodes.menu.error_messages.options_incorrect_range_value', :value => v))
              result = false
            end
          end
          if values.first >= values.last
            errors[:option].push(I18n.t('ivr.nodes.menu.error_messages.options_incorrect_range', :first => values.first.to_s, :last => values.last.to_s))
            result = false
          end
        else
          # Valores separados por comas
          values = self.dtmf.split(',')
          values.each do |v|
            if v.match(/^(\*|#|([0-9]+))$/) == nil
              errors[:option].push(I18n.t('ivr.nodes.menu.error_messages.options_incorrect_dtmf_value', :value => v))
              result = false
            end
          end
          unless values.uniq!.nil?
            errors[:option].push(I18n.t('ivr.nodes.menu.error_messages.options_duplicate_dtmf_value', :value => self.dtmf.dump))
            result = false
          end
        end
        result
      end
  end
end
