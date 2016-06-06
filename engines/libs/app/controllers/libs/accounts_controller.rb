module Libs
  class AccountsController < LibsController
    before_action :add_find, :except => %w(index new create)
    before_action :add_extra_info, :except => %w(delete destroy)

    def index
      @accounts = Libs::Account.where(@global_conditions).order('id DESC').to_a
    end

    def show
    end

    def new
      @account = Libs::Account.new
      reset_cookies :accounts
    end

    def edit
      reset_cookies :accounts
    end

    def create
      @account = Libs::Account.new allowed_params
      reset_cookies :accounts

      if add_data && @account.save
        flash.now[:notice] = I18n.t('messages.success.create')
        redirect_lib
      else
        render :action => :new
      end
    end

    def update
      reset_cookies :accounts

      if @account.update_attributes allowed_params
        flash.now[:notice] = I18n.t('messages.success.update')
        redirect_lib
      else
        render :action => :edit
      end
    end

    def delete
    end

    def destroy
      if @account.destroy
        flash.now[:notice] = I18n.t('messages.success.destroy')
      else
        flash.now[:error] = I18n.t('messages.error.server')
      end

      js_redirect_to accounts_path
    end

    private

      def add_find
        @account = Libs::Account.where(id: params[:id]).first
        js_redirect_to account_path(params[:id]) if @account.users_id.blank? && params[:action] != 'show' && not WEBO_CONFIG['users']['administrators'].include? session[:user]['data']['id']
        render_error 403 if session[:user]['data']['id'] != @account.users_id || (external_engine && @account.product != external_engine)
      end

      def add_extra_info
        @products = @products.delete_if{ |x| not LIBS_CONFIG['products_libs'][x[:value]].include? 'accounts' } unless external_engine

        available_types = LIBS_CONFIG['accounts']['type'].rclone
        available_types = available_types.delete_if{ |x| LIBS_CONFIG['disabled_features']['accounts'].include? x['value'] } unless %w(development test).include? Rails.env
        @type = available_types.each{ |x| x['text'] = I18n.t(x['text']) }
      end

      def add_data
        @account.product = external_engine if external_engine
        @account.users_id = session[:user]['data']['id']
      end

      def redirect_lib
        redirect :accounts, @account.id, @account.name, accounts_path
      end

      def allowed_params
        permit_fields = [
          :name,
          :type,
          :email,
          :server,
          :port,
          :folder,
          :user,
          :password,
          :url
        ]
        permit_fields.push :product unless external_engine
        params.require(:account).permit permit_fields
      end
  end
end
