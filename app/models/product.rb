class Product < ActiveRecord::Base
  self.table_name = 'products'

  has_many :users_products, :class_name => 'UserProduct', :foreign_key => 'products_id', :dependent => :destroy
  has_many :users, :through => :users_products
end