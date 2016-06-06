module Libs
  class Audio < ActiveRecord::Base
    self.table_name = 'libs.audios'

    attr_accessor :path

    has_attached_file :att, :path => "#{LIBS_CONFIG['attachments']['audios']}/:user_id/:id.:extension"

    validates_presence_of :name
    validates_attachment_presence :att, :message => I18n.t('errors.messages.no_file')
    validates_attachment_content_type :att, :content_type => MIME_TYPES['audio'], :message => I18n.t('errors.messages.no_audio_file')
    validates_attachment_size :att, :less_than => 10.megabyte, :message => I18n.t('errors.messages.max_size_10mb')

    protected

      after_find do
        self.path = "#{LIBS_CONFIG['attachments']['audios'].split('public')[1]}/#{self.users_id}/#{self.id}.mp3"
      end

      before_save do
        self.product = nil if self.product.blank?
      end

      after_save do
        # Si es necesario, convertimos los archivos de audio al formato correcto
        ApplicationController.helpers.convert_audios self.att.path, %w(wav mp3 al)
      end
  end
end