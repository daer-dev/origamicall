class UserService < ActiveRecord::Base
  self.table_name = 'users_services'

  belongs_to :user, :class_name => 'User', :foreign_key => 'users_id'
  belongs_to :service, :class_name => 'Service', :foreign_key => 'services_id'
end