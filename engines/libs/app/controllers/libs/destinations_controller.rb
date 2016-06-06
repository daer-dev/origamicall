module Libs
  class DestinationsController < LibsController
    before_action :add_find, :except => %w(index new create)
    before_action :add_extra_info, :except => %w(delete destroy)

    def index
      @destinations = Libs::Destination.where(@global_conditions).order('id DESC').to_a
    end

    def show
    end

    def new
      @destination = Libs::Destination.new
      reset_cookies :destinations
    end

    def edit
      reset_cookies :destinations
    end

    def create
      @destination = Libs::Destination.new allowed_params
      reset_cookies :destinations

      if add_data && @destination.save
        flash.now[:notice] = I18n.t('messages.success.create')
        redirect_lib
      else
        render :action => :new
      end
    end

    def update
      reset_cookies :destinations

      if @destination.update_attributes allowed_params
        flash.now[:notice] = I18n.t('messages.success.update')
        redirect_lib
      else
        render :action => :edit
      end
    end

    def delete
    end

    def destroy
      if @destination.destroy
        flash.now[:notice] = I18n.t('messages.success.destroy')
      else
        flash.now[:error] = I18n.t('messages.error.server')
      end

      js_redirect_to destinations_path
    end

    private

      def add_find
        @destination = Libs::Destination.where(id: params[:id]).first
        js_redirect_to destination_path(params[:id]) if @destination.users_id.blank? && params[:action] != 'show' && not WEBO_CONFIG['users']['administrators'].include? session[:user]['data']['id']
        render_error 403 if session[:user]['data']['id'] != @destination.users_id || (external_engine && @destination.product != external_engine)
      end

      def add_extra_info
        @products = @products.delete_if{ |x| not LIBS_CONFIG['products_libs'][x[:value]].include? 'destinations' } unless external_engine
      end

      def add_data
        @destination.product = external_engine if external_engine
        @destination.users_id = session[:user]['data']['id']
      end

      def redirect_lib
        redirect :destinations, @destination.id, @destination.name, destinations_path
      end

      def allowed_params
        permit_fields = [
          :name,
          :phone_number
        ]
        permit_fields.push :product unless external_engine
        params.require(:destination).permit permit_fields
      end
  end
end
