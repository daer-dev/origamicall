module Ivr
  class TransferNode < ActiveRecord::Base
    self.table_name = 'ivr.transfer_nodes'

    has_one :option, :class_name => 'Ivr::Option', :foreign_key => 'ivr_nodes_id', :dependent => :destroy
    has_many :destinations, :class_name => 'Ivr::Destination', :foreign_key => 'ivr_nodes_id', :dependent => :destroy
    has_many :simple_children, :class_name => 'Ivr::Node', :foreign_key => 'parent_id'

    attr_accessor :main_node, :children, :dummy, :ok_node, :error_node, :related_destinations, :valid_destinations

    validates_presence_of :name
    validates_length_of :name, :maximum => 50, :allow_blank => true
    validates_numericality_of :caller_id, :maxtime, :allow_blank => true

    protected

      after_initialize do
        # Destinos
        self.related_destinations ||= { 'd_0' => { 'type' => 'phone', 'percent' => String.new, 'timeout' => IVR_CONFIG['nodes']['transfer']['destinations']['default_timeout'], 'phone_number' => String.new, 'libs_destinations_id' => String.new, 'ivr_variables_id' => String.new } }
      end

      after_find do
        # Opciones
        self.related_destinations = Hash.new
        self.destinations.each{ |x| self.related_destinations["d_#{x.id}"] = x.attributes } unless self.destinations.blank?
        self.related_destinations['d_0'] = { 'type' => 'phone', 'percent' => String.new, 'timeout' => IVR_CONFIG['nodes']['transfer']['destinations']['default_timeout'], 'phone_number' => String.new, 'libs_destinations_id' => String.new, 'ivr_variables_id' => String.new }
      end

      after_create do
        Ivr::Node.dummies_and_allocation self
      end

      after_save do
        # Destinos
        unless self.valid_destinations.blank?
          order = 0
          # Eliminamos los actuales para volver a crearlos
          self.destinations.destroy_all
          self.valid_destinations.each do |destination|
            destination.ivr_nodes_id = self.id
            order += 1
            destination.order = order
            destination.save validate: false
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

      before_validation do
        val = true
        total_percent = 0
        valid_destinations = Array.new
        unless self.related_destinations.blank?
          destinations = self.related_destinations.values.delete_if{ |d| d['phone_number'].blank? && d['ivr_variables_id'].blank? && d['libs_destinations_id'].blank? }
          # Un nodo de este tipo, como es lógico, siempre debe tener destinos asociados
          if destinations.blank?
            val = false
            errors[:base].push(I18n.t('ivr.nodes.transfer.error_messages.destinations'))
          else
            destinations = destinations.each{ |d| d['order'] = '0' unless d.include? 'order' }.sort_by{ |dd| dd['order'] }
            destinations.each do |x|
              new_d = Ivr::Destination.new({
                :percent => x['percent'],
                :timeout => x['timeout'],
                :type => x['type'],
                :phone_number => x['phone_number'],
                :libs_destinations_id => x['libs_destinations_id'],
                :ivr_variables_id => x['ivr_variables_id'],
                :strategy => self.strategy
              })
              # Comprobamos que los datos sean válidos
              unless new_d.valid?
                new_d.errors.each do |a, m|
                  value_error = String.new
                  # Si el campo no tiene valor asignado, y de ahí viene el error, no lo agregamos al mensaje
                  value_error = "\"#{x[a]}\" " unless x[a].blank?
                  # Si además ya lo hemos agregado, aunque ocurra en más campos, no lo volvemos a hacer
                  errors[a].push "#{value_error}#{m}" unless x[a].blank? && errors[a].include? "#{value_error}#{m}"
                end
                val = false
              end
              valid_destinations.push new_d
              # Una vez validado el destino, almacenamos su porcentaje para validarlo junto a los de los demás más tarde
              total_percent += x['percent'].to_i
            end
            # El total de porcentajes debe ser 100
            if self.strategy == 'percent' && total_percent > 100
              val = false
              errors[:percent].push(I18n.t('ivr.nodes.transfer.error_messages.percent'))
            end
          end
        end
        self.valid_destinations = valid_destinations if val
      end
  end
end
