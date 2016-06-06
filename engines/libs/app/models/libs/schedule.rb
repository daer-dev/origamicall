module Libs
  class Schedule < ActiveRecord::Base
    self.table_name = 'libs.schedules'

    has_many :time_slots, :class_name => 'Libs::TimeSlot', :foreign_key => 'libs_schedules_id', :dependent => :destroy
    has_many :holidays, :class_name => 'Libs::Holiday', :foreign_key => 'libs_schedules_id', :dependent => :destroy

    7.times do |d| d += 1
      3.times do |t| t += 1
        attr_accessor "d#{d}_#{t}_1".to_sym, "d#{d}_#{t}_2".to_sym
        validates "d#{d}_#{t}_1".to_sym, "d#{d}_#{t}_2".to_sym, time: true
      end
    end
    attr_accessor :holidays_list

    validates_presence_of :name
    validates_uniqueness_of :name, :scope => :users_id
    validates :holidays_list, date_list: true

    protected

      after_find do
        # Horarios
        ts = Libs::TimeSlot.where(libs_schedules_id: self.id).to_a
        unless ts.blank?
          7.times do |d|
            d += 1
            3.times do |o|
              o += 1
              h = ts.select{ |x| x.day == d.to_s && x.order == o }[0]
              unless h.blank?
                eval("self.d#{d}_#{o}_1 = h.start") unless h.start.blank?
                eval("self.d#{d}_#{o}_2 = h.end") unless h.end.blank?
              end
            end
          end
        end
        # Festivos
        self.holidays_list = Libs::Holiday.find_by_string self.id
      end

      before_save do
        self.product = nil if self.product.blank?
      end

      after_save do
        # Franjas y festivos
        Libs::TimeSlot.create_by_obj self
        Libs::Holiday.create_by_string self.id, self.holidays_list
      end

    private

      before_validation do
        # El fin de un horario debe ser siempre superior a su inicio (y viceversa)
        7.times do |d| d += 1
          3.times do |t| t += 1
            errors["d#{d}_#{t}_2".to_sym].push(I18n.t('libs.schedules.error_messages.dx_x_2')) if (not eval("self.d#{d}_#{t}_1").blank? && eval("self.d#{d}_#{t}_2").blank?) || (eval("self.d#{d}_#{t}_1").blank? && not eval("self.d#{d}_#{t}_2").blank?) || (not eval("self.d#{d}_#{t}_1").blank? && not eval("self.d#{d}_#{t}_2").blank? && eval("self.d#{d}_#{t}_1") > eval("self.d#{d}_#{t}_2"))
          end
        end
      end
  end
end
