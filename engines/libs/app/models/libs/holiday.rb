module Libs
  class Holiday < ActiveRecord::Base
    self.table_name = 'libs.holidays'

    belongs_to :schedules, :class_name => 'Libs::Schedule', :foreign_key => 'libs_schedules_id'

    def self.create_by_string(schedule_id, days)
      Libs::Holiday.destroy_all :libs_schedules_id => schedule_id
      unless days.blank?
        days = days.split(',').uniq
        days.each do |d|
          d = d.split('/')
          holiday = Libs::Holiday.new({
            :day => "#{d[2]}-#{d[1]}-#{d[0]}",
            :libs_schedules_id => schedule_id
          })
          holiday.save
        end
      end
    end

    def self.find_by_string(schedule_id)
      holidays = Libs::Holiday.where(libs_schedules_id: schedule_id).to_a
      holidays_string = String.new
      holidays.each do |h|
        holidays_string += "#{ApplicationController.helpers.format_timestamp(h.day, '%d/%m/%Y')},"
      end
      holidays_string[0..-2]
    end
  end
end