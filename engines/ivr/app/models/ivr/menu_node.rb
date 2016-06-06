module Ivr
  class MenuNode < ActiveRecord::Base
    self.table_name = 'ivr.menu_nodes'

    has_one :option, :class_name => 'Ivr::Option', :foreign_key => 'ivr_nodes_id', :dependent => :destroy
    has_many :options, :class_name => 'Ivr::Option', :foreign_key => 'ivr_menu_nodes_id', :dependent => :destroy
    has_many :audios, :class_name => 'Ivr::Audio', :foreign_key => 'ivr_nodes_id', :dependent => :destroy
    has_many :nodes_grammars, :class_name => 'Ivr::NodeGrammar', :foreign_key => 'ivr_nodes_id', :dependent => :destroy
    has_many :grammars, :through => :nodes_grammars
    has_many :simple_children, :class_name => 'Ivr::Node', :foreign_key => 'parent_id'

    attr_accessor :main_node, :children, :dummy, :grammar, :grammar_options, :prompt, :no_match, :related_options

    validates_presence_of :name
    validates_length_of :name, :maximum => 50, :allow_blank => true
    validates_numericality_of :timeout
    validates_numericality_of :times, :greater_than_or_equal_to => 1
    validates_presence_of :grammar, :if => :validates_grammar

    protected

      after_initialize do
        # Audios
        self.no_match ||= { :libs_audios_id => String.new, :text => String.new, :tts_voice => String.new }
        self.prompt ||= { :libs_audios_id => String.new, :text => String.new, :tts_voice => String.new }
        # Opciones
        self.related_options ||= { 'o_0' => { 'id' => String.new, 'type' => String.new, 'default' => true, 'dtmf' => String.new, 'libs_options_id' => String.new } }
      end

      after_find do
        # Audios
        unless self.audios.blank?
          self.prompt = self.audios.select{ |x| x.type == 'prompt' }[0]
          self.no_match = self.audios.select{ |x| x.type == 'no_match' }[0]
        end
        # Gramática
        unless self.grammars.blank?
          g = self.grammars[0]
          self.grammar = g.id
          self.grammar_options = g.options
        end
        # Opciones
        self.related_options = Hash.new
        self.options.each{ |x| self.related_options["o_#{x.id}"] = x.attributes.merge({ 'type' => x.node.real_type }) } unless self.options.blank?
        self.related_options['o_0'] = { 'id' => String.new, 'type' => String.new, 'default' => false, 'dtmf' => String.new, 'libs_options_id' => String.new }
      end

      after_create do
        # De esta forma podemos saber si estamos creando un nuevo registro en el callback "after_save" (ya que, lógicamente, en ese caso el atributo "new_record?" no funciona)
        # No se puede llamar al "allocate_children" directamente en este callback, porque antes hay que crear el nodo de la opción predeterminada
        @new_record = true
      end

      after_save do
        # Audios
        # Borramos todas las locuciones asociadas hasta el momento y agregamos las nuevas
        self.audios.destroy_all
        %w(prompt no_match).each do |x|
          new_a = Ivr::Audio.new({
            :libs_audios_id => eval("self.#{x}['libs_audios_id']"),
            :text => eval("self.#{x}['text']"),
            :tts_voice => eval("self.#{x}['tts_voice']"),
            :type => x,
            :ivr_nodes_id => self.id
          })
          new_a.save
        end
        # Guardamos la gramática asociada
        self.nodes_grammars.destroy_all
        unless self.grammar.blank?
          new_g = Ivr::NodeGrammar.new({
            :libs_grammars_id => self.grammar,
            :ivr_nodes_id => self.id
          })
          new_g.save
        end
        # Continuamos con el proceso de creación / actualización
        unless @valid_options.blank?
          @valid_options.each do |x|
            # Nuevo elemento
            if x[2].blank?
              # Seteamos los datos de opción
              new_o = x[0]
              new_o.ivr_menu_nodes_id = self.id
              # Creamos el nodo
              new_n = Ivr::Node.create_dummy_node self, x[1]
              # Si va a ser la opción predeterminada, guardamos su ID
              @default_option = new_n.id if new_o.default
              # Creamos la opción
              new_o.ivr_nodes_id = new_n.id
              new_o.save validate: false
            else
              # Update
              o = self.options.select{ |xx| xx.id.to_s == x[2] }[0]
              o.attributes = x[0].attributes.delete_if{ |k,v| %w(ivr_nodes_id ivr_menu_nodes_id).include? k }
              o.save validate: false
            end
          end
        end
        # Reasignación de nodos (a la opción predeterminada)
        Ivr::Node.allocate_children self, @default_option unless @new_record.blank?
      end

      after_destroy do
        Ivr::Node.delete_children self
      end

    private

      # Si se activa el ASR, ha de seleccionarse una gramática
      def validates_grammar
        self.asr
      end

      # Recorremos todas las opciones, mostrando un mensaje de error en caso de que no estén bien configuradas
      def options_process
        # Quitamos del hash las que tienen los dos datos principales en blanco (y no son la predeterminada)
        self.related_options.delete_if{ |k,v| k != 'o_0' && v['default'].blank? && v['dtmf'].blank? && v['libs_options_id'].blank? } unless self.related_options.blank?
        # Borramos las que no necesitemos
        updated_options = Array.new
        self.related_options.each{ |k,v| updated_options.push v['id'] unless v['id'].blank? }
        deleted_options = self.options.where("id NOT IN(#{updated_options.join(',')})").to_a unless updated_options.blank?
        deleted_options.each{ |x| x.node.destroy; x.destroy } unless deleted_options.blank?
        # Validamos el resto
        dtmf_options = Array.new
        @valid_options = Array.new
        self.related_options.each do |k,v|
          new_o = Ivr::Option.new({
            :dtmf => v['dtmf'],
            :default => (v['default'].blank? ? false : true),
            :libs_options_id => v['libs_options_id']
          })
          new_o.id = v['id'] unless v['id'].blank?
          # Si la opción valida, la tenemos en cuenta para el cálculo de la longitud del menu y la añadimos al array
          if new_o.valid?
            dtmf = [ v['dtmf'], v['dtmf'] ]
            dtmf = v['dtmf'].split('-').sort if v['dtmf'].include? '-'
            if v['dtmf'].include? ','
              dtmf_list = v['dtmf'].split(',').sort
              dmtf = [ dtmf_list[0], dtmf_list.last ]
            end
            self.maxlen = dtmf[0].length unless self.maxlen >= dtmf[0].length
            @valid_options.push [ new_o, v['type'], (v['id'].blank? ? String.new : v['id']) ]
            dtmf_options += new_o.dtmf_values
          elsif k != 'o_0'
            new_o.errors.each do |a, m|
              errors[a].push(m)
            end
          end
        end
        # Comprobamos que no hay valores duplicados entre opciones
        errors[:option].push(I18n.t('ivr.nodes.menu.error_messages.duplicate_dtmf_values')) unless dtmf_options.uniq!.blank?
      end

      before_validation do
        options_process
        # La locución "no match" es obligatoria si existe la posibilidad de que se reproduzca (si hay repeticiones)
        errors[:no_match].push(I18n.t('errors.messages.blank')) if self.times > 0 && self.no_match['libs_audios_id'].blank? && self.no_match['text'].blank?
        # Un menu siempre debe tener alguna opción asociada
        if self.related_options.blank?
          errors[:base].push(I18n.t('ivr.nodes.menu.error_messages.without_options'))
        else
          # No puede haber valores DTMF repetidos
          dtmf_valid_options = Array.new
          self.related_options.each{ |k,v| dtmf_valid_options.push v['dtmf'] unless dtmf_valid_options.include? v['dtmf'] }
          repeated_dtmf_validation_options = if self.related_options.include?('o_0') && self.related_options['o_0']['dtmf'] == String.new && not self.related_options.select{ |k,v| v['dtmf'] == String.new && k != 'o_0' }.blank?
            self.related_options.delete_if{ |k,v| k == 'o_0' }
          else
            self.related_options
          end
          errors[:base].push(I18n.t('ivr.nodes.menu.error_messages.options_with_repeated_dtmf_values')) if dtmf_valid_options.length != repeated_dtmf_validation_options.length
          # Siempre tiene que haber una opción marcada como predeterminada
          errors[:base].push(I18n.t('ivr.nodes.menu.error_messages.without_default_option')) if self.related_options.select{ |k,v| v['default'] }.blank?
          # Si se activa el ASR, tampoco se permite la elección de valores repetidos
          if self.asr
            asr_options = self.related_options.map{ |k,v| v['libs_options_id'] unless v['libs_options_id'].blank? }
            errors[:base].push(I18n.t('ivr.nodes.menu.error_messages.options_with_repeated_asr_values')) unless (asr_options - asr_options.uniq).blank?
          end
        end
      end
  end
end
