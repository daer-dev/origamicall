module Ivr
  class AudioNode < ActiveRecord::Base
    self.table_name = 'ivr.audio_nodes'

    has_one :option, :class_name => 'Ivr::Option', :foreign_key => 'ivr_nodes_id', :dependent => :destroy
    has_many :audios, :class_name => 'Ivr::Audio', :foreign_key => 'ivr_nodes_id', :dependent => :destroy
    has_many :simple_children, :class_name => 'Ivr::Node', :foreign_key => 'parent_id'

    attr_accessor :main_node, :children, :dummy, :related_audios

    validates_presence_of :name
    validates_length_of :name, :maximum => 50, :allow_blank => true

    protected

      after_initialize do
        # Audios
        self.related_audios ||= { 'a_0' => { 'libs_audios_id' => String.new, 'text' => String.new, 'tts_voice' => String.new } }
      end

      after_find do
        # Audios
        self.related_audios = Hash.new
        self.audios.each{ |x| self.related_audios["a_#{x.id}"] = x.attributes } unless self.audios.blank?
        self.related_audios['a_0'] = { 'libs_audios_id' => String.new, 'text' => String.new, 'tts_voice' => String.new }
      end

      after_create do
        Ivr::Node.allocate_children self
      end

      after_save do
        # Borramos todos los audios asociados hasta el momento y agregamos los nuevos
        self.audios.destroy_all
        unless self.related_audios.blank?
          # Ordenamos el listado y lo iteramos
          order = 0
          audios = self.related_audios.values.each{ |a| a['order'] = '0' unless a.include? 'order' }.sort_by{ |aa| aa['order'] }
          audios.each do |x|
            new_a = Ivr::Audio.new({
              :libs_audios_id => x['libs_audios_id'],
              :text => x['text'],
              :tts_voice => x['tts_voice'],
              :ivr_nodes_id => self.id
            })
            @first_new_audio = new_a if audios.index(x) == 0
            # Comprobamos que los datos sean válidos
            if new_a.valid?
              # Si hay datos en el formulario de creación, cambiamos el orden del listado
              order += 1 if not audios.index(x) == 0 && not @first_new_audio.blank? && @first_new_audio.valid?
              # Guardamos el objeto
              order += 1
              new_a.order = order
              new_a.save
            end
          end
        end
      end

      after_destroy do
        Ivr::Node.delete_children self
      end

    private

      before_validation do
        # Un nodo de este tipo, como es lógico, siempre debe tener audios asociados
        errors[:base].push(I18n.t('ivr.nodes.audio.error_messages.audios')) if not self.related_audios.blank? && self.related_audios.values.delete_if{ |x| x['libs_audios_id'].blank? && x['text'].blank? }.blank?
      end
  end
end
