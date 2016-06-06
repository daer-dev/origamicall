module Libs
  class Option < ActiveRecord::Base
    self.table_name = 'libs.options'

    belongs_to :grammar, :class_name => 'Libs::Grammar', :foreign_key => 'libs_grammars_id'
    has_many :values, :class_name => 'Libs::Value', :foreign_key => 'libs_options_id', :dependent => :destroy

    attr_accessor :related_values

    validates_uniqueness_of :name, :scope => :libs_grammars_id

    protected

      after_find do
        self.related_values = self.values.map{ |x| x.name }.join(',')
      end
  end
end