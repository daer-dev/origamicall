module Libs
  class LayoutsController < LibsController
    def index
      render :file => 'layouts/products', :layout => false
    end
  end
end