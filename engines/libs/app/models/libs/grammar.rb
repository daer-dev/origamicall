module Libs
  class Grammar < ActiveRecord::Base
    self.table_name = 'libs.grammars'

    has_many :options, :class_name => 'Libs::Option', :foreign_key => 'libs_grammars_id', :dependent => :destroy
    has_many :values, :through => :options, :dependent => :destroy

    attr_accessor :related_options

    validates_presence_of :name
    validates_uniqueness_of :name, :scope => :users_id

    protected

      after_initialize do
        # Opciones
        self.related_options ||= { 'o_0' => { 'name' => String.new, 'related_values' => String.new } }
      end

      after_find do
        # Opciones
        self.related_options = Hash.new
        self.options.each{ |x| self.related_options["o_#{x.id}"] = x.attributes.merge({ 'related_values' => x.related_values }) } unless self.options.blank?
        self.related_options['o_0'] = { 'name' => String.new, 'related_values' => String.new }
      end

      before_save do
        self.product = nil if self.product.blank?
      end

      after_save do
        # Borramos todos los datos existentes para posteriormente agregar los nuevos
        self.options.destroy_all
        # Opciones
        unless self.related_options.blank?
          self.related_options.each do |k,o|
            unless o['name'].blank? || o['related_values'].blank?
              new_o = Libs::Option.new({
                name: o['name'],
                libs_grammars_id: self.id
              })
              new_o.save
              # Valores
              o['related_values'].split(',').each do |v|
                new_v = Libs::Value.new({
                  name: v,
                  libs_options_id: new_o.id
                })
                new_v.save
              end
            end
          end
        end
      end
  end
end
