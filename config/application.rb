require File.expand_path('../boot', __FILE__)

require 'rails/all'
require 'paperclip'

Bundler.require(*Rails.groups)

WEBO_CONFIG = YAML::load_file(File.join(File.dirname(File.expand_path(__FILE__)), 'webo.yml'))

module Webo
  class Application < Rails::Application
    config.exceptions_app = proc{ |env| ErrorsController.action(:render_message).call(env) }
    # FIXME: Tener "allow_concurrency" activado y "eager_load" desactivado produce un error "Circular dependency...".
    # Esto es un bug y ha de comprobarse si ha sido solucionado antes de cambiar cualquiera de los dos parámetros:
    # http://robots.thoughtbot.com/how-to-fix-circular-dependency-errors-in-rails-integration-tests
    #config.allow_concurrency = true
    config.active_support.escape_html_entities_in_json = true
    config.gem 'paperclip'
    # URLs
    config_default_url_options = {
      :host => WEBO_CONFIG['default_url_options']['host'],
      :protocol => WEBO_CONFIG['default_url_options']['protocol']
    }
    config.action_controller.default_url_options = config_default_url_options
    config.action_mailer.default_url_options = config_default_url_options
    # I18n
    config.i18n.default_locale = WEBO_CONFIG['locale']['default']
    config.i18n.load_path += Dir[Rails.root.join('engines', '*', 'config', 'locales', '*', '*.yml')]
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '*_*', '*.yml')]
    config.encoding = 'utf-8'
    I18n.config.enforce_available_locales = false
    # Parámetros
    # FIXME: Descomentar la siguiente línea cuando no haga falta usar "tap do |whitelisted|" para permitir atributos de tipo Hash con claves dinámicas
    #config.action_controller.action_on_unpermitted_parameters = :raise
    # Envío de emails
    config.action_mailer.delivery_method = :sendmail
    config.action_mailer.smtp_settings = {
      address: 'localhost',
      port: 25
    }
    # Assets
    config.assets.enabled = true
    config.assets.initialize_on_precompile = false
    config.assets.version = '1.0'
    config.assets.logger = nil
    config.assets.paths += [
      Rails.root.join('engines', '*', 'vendor', 'assets', 'javascripts'),
      Rails.root.join('engines', '*', 'vendor', 'assets', 'stylesheets'),
      Rails.root.join('vendor', 'assets', 'flash'),
      Rails.root.join('vendor', 'assets', 'fonts'),
      Rails.root.join('vendor', 'assets', 'images'),
      Rails.root.join('vendor', 'assets', 'javascripts'),
      Rails.root.join('vendor', 'assets', 'stylesheets'),
      Rails.root.join('vendor', 'assets', 'sounds')
    ]
    config.assets.precompile << /(^[^_\/]|\/[^_])[^\/]*$/
  end
end