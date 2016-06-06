module Ivr
  class Destination < ActiveRecord::Base
    self.table_name = 'ivr.destinations'

    # Evitamos que Rails utilice "type" como columna de herencia
    self.inheritance_column = nil

    belongs_to :node, :class_name => 'Ivr::Node', :foreign_key => 'ivr_nodes_id'

    attr_accessor :strategy

    validates_presence_of :phone_number, :if => :validates_phone_number
    validates :phone_number, global_phone: true, :if => :validates_phone_number
    validates_presence_of :ivr_variables_id, :if => :validates_ivr_variables_id
    validates_presence_of :libs_destinations_id, :if => :validates_libs_destinations_id
    validates_presence_of :percent, :if => :validates_percent
    validates_numericality_of :percent, :allow_blank => true, :if => :validates_percent
    validates_numericality_of :timeout, :allow_blank => true

    private

      # Si el tipo es "phone", validamos que hayan introducido un número
      def validates_phone_number
        self.type == 'phone'
      end

      # Si el tipo es "var" y nuestra tree no es "One", validamos que hayan seleccionado una variable
      def validates_ivr_variables_id
        self.type == 'var'
      end

      # Si el tipo es "destination", validamos que hayan seleccionado un destino
      def validates_libs_destinations_id
        self.type == 'destination'
      end

      # El porcentaje sólo es obligatorio si así lo determina la estrategia
      def validates_percent
        self.strategy == 'percent'
      end
  end
end