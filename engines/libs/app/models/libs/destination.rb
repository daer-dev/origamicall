module Libs
  class Destination < ActiveRecord::Base
    self.table_name = 'libs.destinations'

    validates_presence_of :name, :phone_number
    validates_uniqueness_of :name, :scope => :users_id
    validates :phone_number, national_phone: true

    protected

      before_save do
        self.product = nil if self.product.blank?
      end
  end
end