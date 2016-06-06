module Libs
  class Table < ActiveRecord::Base
    self.table_name = 'libs.tables'

    has_many :rows, :class_name => 'Libs::Row', :foreign_key => 'libs_tables_id', :dependent => :destroy

    validates_presence_of :name
    validates_uniqueness_of :name, :scope => :users_id

    attr_accessor :related_rows

    protected

      after_initialize do
        # Datos
        self.related_rows ||= { 'r_0' => { 'name' => String.new, 'value' => String.new } }
      end

      after_find do
        # Datos
        self.related_rows = Hash.new
        self.rows.each{ |x| self.related_rows["r_#{x.id}"] = x.attributes } unless self.rows.blank?
        self.related_rows['r_0'] = { 'name' => String.new, 'value' => String.new }
      end

      before_save do
        self.product = nil if self.product.blank?
      end

      after_save do
        # Borramos todos los datos existentes para posteriormente agregar los nuevos
        self.rows.destroy_all
        # Datos
        unless self.related_rows.blank?
          self.related_rows.each do |k,v|
            new_r = Libs::Row.new({
              :name => v['name'],
              :value => v['value'],
              :libs_tables_id => self.id
            })
            new_r.save if new_r.valid?
          end
        end
      end
  end
end