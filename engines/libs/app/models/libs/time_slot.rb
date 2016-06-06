module Libs
  class TimeSlot < ActiveRecord::Base
    self.table_name = 'libs.time_slots'

    belongs_to :schedules, :class_name => 'Libs::Schedule', :foreign_key => 'libs_schedules_id'

    def self.create_by_obj(obj)
      Libs::TimeSlot.destroy_all :libs_schedules_id => obj.id
      rows = [
        { :start => obj.d1_1_1, :end => obj.d1_1_2, :order => 1, :day => 1  },
        { :start => obj.d1_2_1, :end => obj.d1_2_2, :order => 2, :day => 1  },
        { :start => obj.d1_3_1, :end => obj.d1_3_2, :order => 3, :day => 1  },
        { :start => obj.d2_1_1, :end => obj.d2_1_2, :order => 1, :day => 2  },
        { :start => obj.d2_2_1, :end => obj.d2_2_2, :order => 2, :day => 2  },
        { :start => obj.d2_3_1, :end => obj.d2_3_2, :order => 3, :day => 2  },
        { :start => obj.d3_1_1, :end => obj.d3_1_2, :order => 1, :day => 3  },
        { :start => obj.d3_2_1, :end => obj.d3_2_2, :order => 2, :day => 3  },
        { :start => obj.d3_3_1, :end => obj.d3_3_2, :order => 3, :day => 3  },
        { :start => obj.d4_1_1, :end => obj.d4_1_2, :order => 1, :day => 4  },
        { :start => obj.d4_2_1, :end => obj.d4_2_2, :order => 2, :day => 4  },
        { :start => obj.d4_3_1, :end => obj.d4_3_2, :order => 3, :day => 4  },
        { :start => obj.d5_1_1, :end => obj.d5_1_2, :order => 1, :day => 5  },
        { :start => obj.d5_2_1, :end => obj.d5_2_2, :order => 2, :day => 5  },
        { :start => obj.d5_3_1, :end => obj.d5_3_2, :order => 3, :day => 5  },
        { :start => obj.d6_1_1, :end => obj.d6_1_2, :order => 1, :day => 6  },
        { :start => obj.d6_2_1, :end => obj.d6_2_2, :order => 2, :day => 6  },
        { :start => obj.d6_3_1, :end => obj.d6_3_2, :order => 3, :day => 6  },
        { :start => obj.d7_1_1, :end => obj.d7_1_2, :order => 1, :day => 7  },
        { :start => obj.d7_2_1, :end => obj.d7_2_2, :order => 2, :day => 7  },
        { :start => obj.d7_3_1, :end => obj.d7_3_2, :order => 3, :day => 7  }
      ]
      rows.each do |r|
        unless r[:start].blank? || r[:end].blank?
          ts = Libs::TimeSlot.new(r.merge({ :libs_schedules_id => obj.id }))
          ts.save
        end
      end
    end
  end
end
