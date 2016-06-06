unless %w(development test).include? Rails.env
  I18n.backend.class.send(:include, I18n::Backend::Fallbacks)

  # Hacemos que, en caso de fallo, todos los "locales" consulten al establecido por defecto
  WEBO_CONFIG['locale']['list'].each do |x|
    I18n.fallbacks[x['id']] = WEBO_CONFIG['locale']['default'] unless x['id'] == WEBO_CONFIG['locale']['default']
  end
end