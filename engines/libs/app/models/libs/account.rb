module Libs
  class Account < ActiveRecord::Base
    self.table_name = 'libs.accounts'

    # Evitamos que Rails utilice "type" como columna de herencia
    self.inheritance_column = nil

    validates_presence_of :name
    validates_uniqueness_of :name, :scope => :users_id
    validates :email, email: true, :if => :validates_email
    validates_presence_of :email, :if => :validates_email
    validates :url, url: true, :if => :validates_http
    validates_presence_of :url, :if => :validates_http
    validates_numericality_of :port, :allow_blank => true, :if => :validates_ftp
    validates_presence_of :server, :port, :folder, :user, :password, :if => :validates_ftp

    protected

      after_initialize do
        self.type ||= 'email'
      end

      before_save do
        self.product = nil if self.product.blank?
      end

    private

      # Dependiendo del tipo que se elija, se requieren unos campos u otros
      def validates_email
        self.type == 'email'
      end

      def validates_http
        self.type == 'post'
      end

      def validates_ftp
        %w(ftp sftp).include? self.type
      end
  end
end