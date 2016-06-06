module Ivr
  class TreesController < IvrController
    include Ivr::TreeHelper

    before_action :add_find, :except => %w(index new create)
    before_action :add_extra_info, :except => %w(index export delete destroy)

    def index
      Ivr::Tree.callback_after_find = false
      @trees = Ivr::Tree.where(@global_conditions).order('id DESC').to_a
      Ivr::Tree.callback_after_find = true
    end

    def show
    end

    def export
      render :text => @tree.nodes.to_json
    end

    def new
      @tree = Ivr::Tree.new
    end

    def edit
    end

    def create
      @tree = Ivr::Tree.new allowed_params

      if add_data && @tree.save
        flash.now[:notice] = I18n.t('messages.success.create')
        js_redirect_to edit_tree_path @tree
      else
        render :action => :new
      end
    end

    def update
      if @tree.update_attributes allowed_params
        flash.now[:notice] = I18n.t('messages.success.update')
        js_redirect_to trees_path
      else
        render :action => :edit
      end
    end

    def delete
    end

    def destroy
      if @tree.destroy
        flash.now[:notice] = I18n.t('messages.success.destroy')
      else
        flash.now[:error] = I18n.t('messages.error.server')
      end

      js_redirect_to trees_path
    end

    private

      def add_find
        @tree = Ivr::Tree.where(id: params[:id]).first

        if @tree.blank?
          render_error 404
        elsif session[:user]['data']['id'] != @tree.users_id
          render_error 403
        end
      end

      def add_extra_info
        # Servicios
        @related_services = Array.new
        s = Ivr::TreeService.where(ivr_trees_id: params[:id]).to_a
        s.each{ |x| @related_services.push x.services_id.to_s }
        # SpaceTree
        if %w(show edit update).include? params[:action]
          spacetree_preferences
          # Si estamos viendo la versión completa del árbol, desactivamos tanto la llamada al "partial" de mensajes, como a la función JS "pageSetUp"
          if params.include? :window
            @no_messages = true
            @no_page_setup = true
          end
        end
      end

      def add_data
        @tree.users_id = session[:user]['data']['id']
      end

      def allowed_params
        params.require(:tree).permit(
          :name
        ).tap do |whitelisted|
          whitelisted[:related_services] = params[:tree][:related_services]
        end
      end
  end
end
