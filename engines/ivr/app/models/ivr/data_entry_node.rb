module Ivr
  class DataEntryNode < ActiveRecord::Base
    self.table_name = 'ivr.data_entry_nodes'

    has_one :option, :class_name => 'Ivr::Option', :foreign_key => 'ivr_nodes_id', :dependent => :destroy
    has_many :audios, :class_name => 'Ivr::Audio', :foreign_key => 'ivr_nodes_id', :dependent => :destroy
    has_many :nodes_grammars, :class_name => 'Ivr::NodeGrammar', :foreign_key => 'ivr_nodes_id', :dependent => :destroy
    has_many :grammars, :through => :nodes_grammars
    has_many :simple_children, :class_name => 'Ivr::Node', :foreign_key => 'parent_id'

    attr_accessor :main_node, :children, :dummy, :no_match, :prompt, :disconnect, :related_grammars, :ok_node, :error_node

    validates_presence_of :name
    validates_presence_of :ivr_variables_id
    validates_length_of :name, :maximum => 50, :allow_blank => true
    validates_numericality_of :timeout
    validates_numericality_of :times, :greater_than_or_equal_to => 1
    validates_presence_of :related_grammars, :if => :validates_grammars

    protected

      after_initialize do
        # Audios
        self.no_match ||= { :libs_audios_id => String.new, :text => String.new, :tts_voice => String.new }
        self.prompt ||= { :libs_audios_id => String.new, :text => String.new, :tts_voice => String.new }
        self.disconnect ||= { :libs_audios_id => String.new, :text => String.new, :tts_voice => String.new }
      end

      after_find do
        # Audios
        unless self.audios.blank?
          self.prompt = self.audios.select{ |x| x.type == 'prompt' }[0]
          self.no_match = self.audios.select{ |x| x.type == 'no_match' }[0]
          self.disconnect = self.audios.select{ |x| x.type == 'disconnect' }[0]
        end
      end

      after_create do
        Ivr::Node.dummies_and_allocation self
      end

      before_save do
        # Si no hay gramáticas seleccionadas ni detección de voz activada, modificamos el valor del campo "field_type"
        self.field_type = nil
        self.field_type = 'digits' if self.related_grammars.blank? && not self.asr
      end

      after_save do
        # Borramos todas los audios asociados hasta el momento y agregamos los nuevos
        self.audios.destroy_all
        %w(prompt no_match disconnect).each do |x|
          new_a = Ivr::Audio.new({
            :libs_audios_id => eval("self.#{x}['libs_audios_id']"),
            :text => eval("self.#{x}['text']"),
            :tts_voice => eval("self.#{x}['tts_voice']"),
            :type => x,
            :ivr_nodes_id => self.id
          })
          new_a.save
        end
        # Gramáticas asociadas
        self.nodes_grammars.destroy_all
        unless self.related_grammars.blank?
          self.related_grammars['group_'].each do |k,v|
            new_g = Ivr::NodeGrammar.new({
              :libs_grammars_id => v,
              :ivr_nodes_id => self.id
            })
            new_g.save
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

      # Si se activa el ASR, ha de seleccionarse al menos una gramática
      def validates_grammars
        self.asr
      end

      before_validation do
        # La locución "no match" es obligatoria si existe la posibilidad de que se reproduzca (si hay repeticiones)
        errors[:no_match].push(I18n.t('errors.messages.blank')) if self.times > 0 && self.no_match['libs_audios_id'].blank? && self.no_match['text'].blank?
      end
  end
end
