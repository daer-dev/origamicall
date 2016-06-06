module ServicesHelper
  def save_external_service(data, api = false)
    # Comprobamos que la petición tenga todos los campos requeridos
    fields = %w(id name number)

    if (data.keys & fields).sort == fields.sort
      service = Hash.new
      data.each{ |k,v| service[k.to_s] = v if fields.include? k }

      service_obj = Service.new({
        :number => data['number']
      })
      service_obj.id = data['id']
      service_obj.save

      render text: 200 if api
    else
      render text: 400 if api
    end
  end
end