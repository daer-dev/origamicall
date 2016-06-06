class Service < ActiveRecord::Base
  self.table_name = 'services'

  has_many :users_services, :class_name => 'UserService', :foreign_key => 'services_id', :dependent => :destroy
  has_many :users, :through => :users_services
end