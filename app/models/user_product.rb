class UserProduct < ActiveRecord::Base
  self.table_name = 'users_products'

  belongs_to :user, :class_name => 'User', :foreign_key => 'users_id'
  belongs_to :product, :class_name => 'Product', :foreign_key => 'products_id'
end