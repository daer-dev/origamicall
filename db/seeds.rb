# Capturamos una posible excepción que pueda producirse en alguno de los modelos e interrumpir el despliegue cuando se llama al comando "rake db:seed"
begin
  ActiveRecord::Base.transaction do
    # Productos
    products_ids = Array.new
    WEBO_CONFIG['products'].each do |product|
      unless product['key'] == 'libs'
        product_obj = Product.create!({ :name => product['key'] })
        products_ids.push product_obj.id
      end
    end

    # Usuario de prueba
    user = User.create!({
      :name => 'Test User'
    })
    # Servicios
    %w(11111 22222 33333 44444 55555).each do |service_number|
      service = Service.create!({
        :number => service_number
      })
      user_service = UserService.create!({
        :services_id => service.id,
        :users_id => user.id
      })
    end
    # Productos
    products_ids.each do |product_id|
      UserProduct.create!({
        :products_id => product_id,
        :users_id => user.id
      })
    end

    # Engines
    Dir.entries("#{Rails.root}/engines").delete_if{ |x| %w(.. .).include? x }.each do |engine|
      eval "#{engine.camelize}::Engine.load_seed"
    end
  end
rescue Exception => e
  Rails.logger.error e
  p e
end