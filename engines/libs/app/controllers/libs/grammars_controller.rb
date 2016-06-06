module Libs
  class GrammarsController < LibsController
    before_action :add_find, :except => %w(index new create)
    before_action :add_extra_info, :except => %w(export delete destroy)

    def index
      @grammars = Libs::Grammar.where(@global_conditions).order('id DESC').to_a
    end

    def show
    end

    def export
      render :text => @grammar.options.to_json
    end

    def new
      @grammar = Libs::Grammar.new
      reset_cookies :grammars
    end

    def edit
      reset_cookies :grammars
    end

    def create
      @grammar = Libs::Grammar.new allowed_params
      reset_cookies :grammars

      if add_data && @grammar.save
        flash.now[:notice] = I18n.t('messages.success.create')
        redirect_lib
      else
        render :action => :new
      end
    end

    def update
      reset_cookies :grammars

      if @grammar.update_attributes allowed_params
        flash.now[:notice] = I18n.t('messages.success.update')
        redirect_lib
      else
        render :action => :edit
      end
    end

    def delete
    end

    def destroy
      if @grammar.destroy
        flash.now[:notice] = I18n.t('messages.success.destroy')
      else
        flash.now[:error] = I18n.t('messages.error.server')
      end

      js_redirect_to grammars_path
    end

    private

      def add_find
        @grammar = Libs::Grammar.where(id: params[:id]).includes(:options).first
        js_redirect_to grammar_path(params[:id]) if @grammar.users_id.blank? && params[:action] != 'show' && not WEBO_CONFIG['users']['administrators'].include? session[:user]['data']['id']
        render_error 403 if session[:user]['data']['id'] != @grammar.users_id || (external_engine && @grammar.product != external_engine)
      end

      def add_extra_info
        @products = @products.delete_if{ |x| not LIBS_CONFIG['products_libs'][x[:value]].include? 'grammars' } unless external_engine
      end

      def add_data
        @grammar.product = external_engine if external_engine
        @grammar.users_id = session[:user]['data']['id']
      end

      def redirect_lib
        redirect :grammars, @grammar.id, @grammar.name, grammars_path
      end

      def allowed_params
        permit_fields = [
          :name
        ]
        permit_fields.push :product unless external_engine
        params.require(:grammar).permit(permit_fields).tap do |whitelisted|
          whitelisted[:related_options] = params[:grammar][:related_options]
        end
      end
  end
end
