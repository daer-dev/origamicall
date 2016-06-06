module Libs
  class LibsController < ::ApplicationController
    include Libs::LibsHelper
    helper Libs::Engine.helpers

    layout 'pages'

    before_action :libs_auth, :default_values, unless: :is_public_page?

    def reset_cookies(name)
      if params.include? :window
        # Borramos las cookies por si el usuario cierra la ventana sin finalizar el proceso
        cookies["#{name}_last_id".to_sym] = nil
        cookies["#{name}_last_name".to_sym] = nil
      end
    end

    private

      def libs_auth
        # Si el usuario está intentando ver una librería para la que no tiene ningún producto asociado, se lo impedimos
        lib_name = params[:controller].gsub('libs/', String.new)
        lib_name = lib_name.split('/')[0] if lib_name.include? '/'
        render_error 403 unless params[:controller] == 'libs/layouts' || get_allowed_libs.include? lib_name
      end

      def default_values
        # Layout
        if params[:controller] == 'libs/layouts'
          # Menu: dejamos sólo las librerías para las que tenga permisos, y ponemos el listado de la primera como página principal
          allowed_libs = get_allowed_libs
          @engine_menu = engine_config['menu'].rclone.delete_if{ |x| x.include? 'key' && not allowed_libs.include? x['key'] }
          @engine_menu[0]['link'] = "libs.#{allowed_libs[0]}_path"
        end
        # Hacemos que, si estamos accediendo a las librerías desde otro engine, sólo se vean sus elementos
        @global_conditions = [ 'users_id = ? OR users_id IS NULL', session[:user]['data']['id'] ]
        if external_engine
          @global_conditions[0] = "(#{@global_conditions[0]}) AND product = ?"
          @global_conditions.push external_engine
        else
          # Productos
          @products = Array.new
          (LIBS_CONFIG['products_libs'].rclone.map{ |k,v| k.to_s } & session[:user]['products']).each do |x|
            @products.push({ :value => x, :text => I18n.t("products.#{x}") })
          end
        end
      end
  end
end
