module Ivr
  class LayoutsController < IvrController
    def index
      render :file => 'layouts/products', :layout => false
    end
  end
end