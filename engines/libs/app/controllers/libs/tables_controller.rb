module Libs
  class TablesController < LibsController
    before_action :add_find, :except => %w(index new create)
    before_action :add_extra_info, :except => %w(delete destroy)

    def index
      @tables = Libs::Table.where(@global_conditions).order('id DESC').to_a
    end

    def show
    end

    def new
      @table = Libs::Table.new
      reset_cookies :tables
    end

    def edit
      reset_cookies :tables
    end

    def create
      @table = Libs::Table.new allowed_params
      reset_cookies :tables

      if add_data && @table.save
        flash.now[:notice] = I18n.t('messages.success.create')
        redirect_lib
      else
        render :action => :new
      end
    end

    def update
      reset_cookies :tables

      if @table.update_attributes allowed_params
        flash.now[:notice] = I18n.t('messages.success.update')
        redirect_lib
      else
        render :action => :edit
      end
    end

    def delete
    end

    def destroy
      if @table.destroy
        flash.now[:notice] = I18n.t('messages.success.destroy')
      else
        flash.now[:error] = I18n.t('messages.error.server')
      end

      js_redirect_to tables_path
    end

    private

      def add_find
        @table = Libs::Table.where(id: params[:id]).includes(:rows).first
        js_redirect_to table_path(params[:id]) if @table.users_id.blank? && params[:action] != 'show' && not WEBO_CONFIG['users']['administrators'].include? session[:user]['data']['id']
        render_error 403 if session[:user]['data']['id'] != @table.users_id || (external_engine && @table.product != external_engine)
      end

      def add_extra_info
        @products = @products.delete_if{ |x| not LIBS_CONFIG['products_libs'][x[:value]].include? 'tables' } unless external_engine
      end

      def add_data
        @table.product = external_engine if external_engine
        @table.users_id = session[:user]['data']['id']
      end

      def redirect_lib
        redirect :tables, @table.id, @table.name, tables_path
      end

      def allowed_params
        permit_fields = [
          :name
        ]
        permit_fields.push :product unless external_engine
        params.require(:table).permit(permit_fields).tap do |whitelisted|
          whitelisted[:related_rows] = params[:table][:related_rows]
        end
      end
  end
end
