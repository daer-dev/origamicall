class ApplicationController < ActionController::Base
  include ApplicationHelper
  helper  ApplicationHelper
  include UsersHelper

  before_action :locale
  before_action :auth, unless: :is_public_page?

  private

    def auth
      # Usuario de test
      if session[:user].blank? && (%(development test).include? Rails.env || params.include? :test)
        first_user = User.first
        login_user(first_user.id) unless first_user.blank?
      end

      reset_session    if params.include? :logout
      render_error 403 if session.blank? || session[:user].blank?
    end

    def locale
      # Get
      I18n.locale = cookies[:locale] unless cookies[:locale].blank?
      # Set
      if params.include? :locale && not params[:locale].blank?
        I18n.locale = params[:locale]
        cookies[:locale] = params[:locale]
        begin
          redirect_to :back
        rescue
          redirect_to '/'
        end
      end
    end

    def is_public_page?
      public_pages  = Array.new
      public_pages += WEBO_CONFIG['public_pages'].select{ |x| x['controller'] == params[:controller] } if WEBO_CONFIG.include? 'public_pages'
      public_pages += engine_config['public_pages'].select{ |x| x['controller'] == params[:controller] } if engine_config.include? 'public_pages'

      engine_name == 'company' || params[:action][0..3] == 'api_' || (not public_pages[0].blank? && (not public_pages[0].include? 'actions' || (public_pages[0].include? 'actions' && ((public_pages[0]['actions'].is_a? Array && public_pages[0]['actions'].include? params[:action]) || (public_pages[0]['actions'].is_a? String && public_pages[0]['actions'] == params[:action])))))
    end
end
