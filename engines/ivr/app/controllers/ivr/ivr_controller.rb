module Ivr
  class IvrController < ApplicationController
    include Libs::LibsHelper
    helper Libs::Engine.helpers

    layout 'pages'

    before_action :ivr_auth, :default_values, unless: :is_public_page?

    private

      def ivr_auth
        render_error 403 unless session[:user].include? 'products' && session[:user]['products'].include? 'ivr'
      end

      def default_values
        @global_conditions = [ 'users_id = ?', session[:user]['data']['id'] ]
      end
  end
end
