module UsersHelper
  def login_user(id)
    user = User.where(id: id).first

    if user.blank?
      false
    else
      session[:user] = {
        'data' => user.as_json,
        'services' => user.services.as_json,
        'products' => user.products.to_a.map{ |product| product.name }
      }

      true
    end
  end

  def save_external_user(data)
    # Comprobamos que la petición tenga todos los campos requeridos
    fields = %w(name products services)
    fields.push('id') if data.include? 'id'

    if (data.keys & fields).sort == fields.sort && data['products'].is_a? Array && data['products'].length > 0 && data['services'].is_a? Array && data['services'].length > 0
      user = Hash.new
      data.each{ |k,v| user[k.to_s] = v if fields.include? k }
      # Si el usuario ya existe en la BBDD, lo borramos para actualizar sus datos
      if data.include? 'id'
        existing_user = User.where(id: data['id']).first
        existing_user.destroy unless existing_user.blank?
      end
      # Guardamos los datos en la BBDD
      # Usuario
      user_obj = User.new
      user_obj.id = data['id'] if data.include? 'id'
      user_obj.name = data['name']
      user_obj.save
      # Servicios
      data['services'].each do |service|
        services = Service.all.map{ |x| x.id.to_s }
        # Agregamos sólo los que estén creados
        if services.include? service.to_s
          user_service_obj = UserService.new({
            :services_id => service,
            :users_id => user_obj.id
          })
          user_service_obj.save
        end
      end
      # Productos
      data['products'].each do |product|
        if PRODUCTS.include? product
          product_obj = UserProduct.new({
            :products_id => PRODUCTS[product],
            :users_id => user_obj.id
          })
          product_obj.save
        end
      end
      # Mostramos algo por pantalla
      render text: user_obj.id
    else
      render text: 400
    end
  end
end
