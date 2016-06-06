module Libs
  class List < ActiveRecord::Base
    require 'csv'

    self.table_name = 'libs.lists'

    # Evitamos que Rails utilice "type" como columna de herencia
    self.inheritance_column = nil

    has_many :contacts, :class_name => 'Libs::Contact', :foreign_key => 'libs_lists_id'

    attr_accessor :replace_contacts

    has_attached_file :att, :path => "#{LIBS_CONFIG['attachments']['lists']}/:user_id/:id.:extension"

    validates_presence_of :name, :type
    validates_attachment_content_type :att, :content_type => MIME_TYPES['csv'], :message => I18n.t('errors.messages.no_csv_file')
    validates_attachment_size :att, :less_than => 256.kilobyte, :message => I18n.t('errors.messages.max_size_250kb')
    validates_uniqueness_of :name, :scope => :users_id

    def save(*args)
      if self.valid?
        ActiveRecord::Base.transaction do
          # Guardamos el registro
          super(validate: false)
          # Parseamos el CSV, insertando en la BBDD los teléfonos que contenga, y devolvemos el resultado
          parse_csv
        end
      end
    end

    protected

      before_save do
        self.product = nil if self.product.blank?
      end

      # Save
      def parse_csv
        file_path = "#{LIBS_CONFIG['attachments']['lists']}/#{self.users_id}/#{self.id}.csv"
        summary = [ 0 , 0 ]
        if File.exists? file_path
          Libs::Contact.delete_all :libs_lists_id => self.id if self.replace_contacts == '1'
          file = File.open(file_path, 'rb')
          # Capturamos la excepción por si recibimos un formato no aceptado por el parser
          begin
            CSV.foreach(file) do |row|
              unless row.blank?
                # Agregamos el contacto y lo asociamos a la lista
                t = Libs::Contact.new({
                  :phone_number => row[0],
                  :libs_lists_id => self.id
                })
                # Devolvemos los contadores
                if t.save
                  summary[0] += 1
                else
                  summary[1] += 1
                end
              end
            end
          rescue
          end
          # Cerramos y borramos el archivo
          file.close
          File.delete file_path
        end
        # Devolvemos el resumen
        summary
      end
  end
end