module Libs
  class AudiosController < LibsController
    before_action :add_find, :except => %w(index new create)
    before_action :add_extra_info, :except => %w(delete destroy)

    def index
      @audios = Libs::Audio.where(@global_conditions).order('id DESC').to_a
    end

    def show
    end

    def new
      @audio = Libs::Audio.new
      reset_cookies :audios
    end

    def edit
      reset_cookies :audios
    end

    def create
      @audio = Libs::Audio.new allowed_params
      reset_cookies :audios

      if add_data && @audio.save
        flash.now[:notice] = I18n.t('messages.success.create')
        redirect_lib
      else
        render :action => :new
      end
    end

    def update
      reset_cookies :audios

      if @audio.update_attributes allowed_params
        flash.now[:notice] = I18n.t('messages.success.update')
        redirect_lib
      else
        render :action => :edit
      end
    end

    def delete
    end

    def destroy
      if @audio.destroy
        flash.now[:notice] = I18n.t('messages.success.destroy')
      else
        flash.now[:error] = I18n.t('messages.error.server')
      end

      js_redirect_to audios_path
    end

    private

      def add_find
        @audio = Libs::Audio.where(id: params[:id]).first
        js_redirect_to audio_path(params[:id]) if @audio.users_id.blank? && params[:action] != 'show' && not WEBO_CONFIG['users']['administrators'].include? session[:user]['data']['id']
        render_error 403 if session[:user]['data']['id'] != @audio.users_id || (external_engine && @audio.product != external_engine)
      end

      def add_extra_info
        @products = @products.delete_if{ |x| not LIBS_CONFIG['products_libs'][x[:value]].include? 'audios' } unless external_engine
      end

      def add_data
        @audio.product = external_engine if external_engine
        @audio.users_id = session[:user]['data']['id']
      end

      def redirect_lib
        redirect :audios, @audio.id, @audio.name, audios_path
      end

      def allowed_params
        permit_fields = [
          :name,
          :att
        ]
        permit_fields.push :product unless external_engine
        params.require(:audio).permit permit_fields
      end
  end
end
