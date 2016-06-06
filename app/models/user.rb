class User < ActiveRecord::Base
  self.table_name = 'users'

  has_many :users_services, :class_name => 'UserService', :foreign_key => 'users_id', :dependent => :destroy
  has_many :services, :through => :users_services, :dependent => :destroy
  has_many :users_products, :class_name => 'UserProduct', :foreign_key => 'users_id', :dependent => :destroy
  has_many :products, :through => :users_products, :dependent => :destroy

  protected

    after_find do
      # Logos
      unless self.white_label || (self.white_label && self.no_logo)
        self.logo = 'logo.png' if self.logo.blank?
        self.logo_mini = 'logo_mini.png' if self.logo_mini.blank?
      end
    end
end
