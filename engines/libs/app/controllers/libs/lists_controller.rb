module Libs
  class ListsController < LibsController
    before_action :add_find, :except => %w(index new create)
    before_action :add_extra_info, :except => %w(delete destroy)

    def index
      @lists = Libs::List.includes(:contacts).where(@global_conditions).order("#{Libs::List.table_name}.id DESC").to_a
    end

    def show
    end

    def new
      @list = Libs::List.new
      reset_cookies :lists
    end

    def edit
      reset_cookies :lists
    end

    def create
      @list = Libs::List.new allowed_params
      reset_cookies :lists
      summary = @list.save if add_data

      if summary.is_a?(Array)
        flash.now[:notice] = summary_notice(summary)
        redirect_lib
      else
        render :action => :new
      end
    end

    def update
      reset_cookies :lists
      summary = @list.update_attributes allowed_params

      if summary.is_a?(Array)
        # Si se ha cambiado el tipo o los contactos de la lista, notificamos al sistema
        unless @list.previous_changes.blank?
          update_system_url_params = "/#{@list.id}"
          update_system_url_params += "/type/#{@list.type}" if @list.previous_changes.include? 'type'
          update_system_url_params += "/contacts" if @list.previous_changes.include? 'att_updated_at'
          get_url_response "#{LIBS_CONFIG['lists']['system_urls']['update'][Rails.env]}#{update_system_url_params}"
        end

        flash.now[:notice] = summary_notice(summary)
        redirect_lib
      else
        render :action => :edit
      end
    end

    def delete
    end

    def destroy
      if @list.destroy
        # Notificamos al sistema de la eliminación de la lista
        get_url_response "#{LIBS_CONFIG['lists']['system_urls']['delete'][Rails.env]}/#{@list.id}"

        flash.now[:notice] = I18n.t('messages.success.destroy')
      else
        flash.now[:error] = I18n.t('messages.error.server')
      end

      js_redirect_to lists_path
    end

    private

      def add_find
        @list = Libs::List.where(id: params[:id]).includes(:contacts).first
        js_redirect_to list_path(params[:id]) if @list.users_id.blank? && params[:action] != 'show' && not WEBO_CONFIG['users']['administrators'].include? session[:user]['data']['id']
        render_error 403 if session[:user]['data']['id'] != @list.users_id || (external_engine && @list.product != external_engine)
      end

      def add_extra_info
        @products = @products.delete_if{ |x| not LIBS_CONFIG['products_libs'][x[:value]].include? 'lists' } unless external_engine
        @type = LIBS_CONFIG['lists']['type'].rclone.each{ |x| x['text'] = I18n.t(x['text']) }
      end

      def add_data
        @list.product = external_engine if external_engine
        @list.users_id = session[:user]['data']['id']
      end

      def redirect_lib
        redirect :lists, @list.id, @list.name, lists_path
      end

      def summary_notice(data)
        "#{I18n.t('messages.success.' + params[:action])}</p><p>#{I18n.t('libs.lists.contacts.message', added: data[0], discarded: data[1], total: (data[0] + data[1]))}."
      end

      def allowed_params
        permit_fields = [
          :name,
          :type,
          :att,
          :replace_contacts
        ]
        permit_fields.push :product unless external_engine
        params.require(:list).permit permit_fields
      end
  end
end
