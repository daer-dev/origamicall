module Ivr
  class Audio < ActiveRecord::Base
    self.table_name = 'ivr.audios'

    # Evitamos que Rails utilice "type" como columna de herencia
    self.inheritance_column = nil

    belongs_to :node, :class_name => 'Ivr::Node', :foreign_key => 'ivr_nodes_id'

    validates_presence_of :libs_audios_id, :if => :validates_audio
    validates_presence_of :text, :if => :validates_text

    private

      # Se debe rellenar al menos uno de los dos campos (audio o TTS)
      def validates_audio
        self.text.blank?
      end

      # Idem
      def validates_text
        self.libs_audios_id.blank?
      end
  end
end