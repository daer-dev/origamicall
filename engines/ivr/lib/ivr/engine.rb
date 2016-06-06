module Ivr
  class Engine < ::Rails::Engine
    isolate_namespace Ivr

    # Hacemos que las migraciones de este engine se tengan en cuenta en la aplicación principal
    initializer :append_migrations do |app|
      unless app.root.to_s.match root.to_s
        config.paths['db/migrate'].expanded.each do |expanded_path|
          app.config.paths['db/migrate'].push expanded_path
        end
      end
    end
  end
end