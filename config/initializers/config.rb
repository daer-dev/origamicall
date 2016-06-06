# Mime types
MIME_TYPES = YAML.load_file("#{Rails.root}/config/mime_types.yml")

# Productos
begin
  products = Hash.new
  Product.all.each{ |x| products[x.name] = x.id }
  PRODUCTS = products
rescue
end

# Engines
Dir.entries("#{Rails.root}/engines").each do |engine|
  config_file_path = "#{Rails.root}/engines/#{engine}/config/#{engine}.yml"
  if File.exists? config_file_path
    loaded_data = YAML.load_file(config_file_path)
    eval("#{engine.upcase}_CONFIG = loaded_data")
    # Attachments
    if loaded_data.include? 'attachments'
      loaded_data['attachments'].each do |k,v|
        loaded_data['attachments'][k] = "#{Rails.root}/public/resources/#{engine}/#{v}"
      end
    end
  end
end