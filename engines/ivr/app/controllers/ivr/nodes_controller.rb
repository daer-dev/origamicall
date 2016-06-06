module Ivr
  class NodesController < IvrController
    include Ivr::TreeHelper

    before_action :add_find, :except => %w(index new create)
    before_action :add_find_parent, :only => %w(new create)
    before_action :add_extra_info, :only => %w(edit update)
    before_action :root_destroy, :only => %w(delete destroy)
    before_action :unset_reload_cookie, :only => %w(new edit delete disable)

    def index
    end

    def show
      show_file = "ivr/nodes/#{@type}/new"

      if File.exists? "#{Rails.root}/engines/ivr/app/views/#{show_file}.html.erb"
        render show_file
      else
        js_redirect_to edit_tree_node_path params[:tree_id], params[:id]
      end
    end

    def new
      if params[:type].blank?
        render_new_form
      else
        # Comprobamos que el tipo proporcionado esté admitido
        if get_allowed_node_types(@type).map{ |x| x[:id] }.include? @type
          new_object
          render_new_form
        else
          render_error 403
        end
      end
    end

    def edit
    end

    def create
      new_object allowed_params
      @node.parent_id = params[:parent]

      if @node.save
        set_cookies @node.id, @node.active
        close_div_and_compute_graph
      else
        render_new_form
      end
    end

    def update
      params_data = params["#{@type}_node".to_sym]

      if params_data.include? :active
        # Si sólo queremos actualizar el campo "active", lo hacemos directamente sobre la BBDD para evitar la ejecución de los callbacks presentes
        result = ActiveRecord::Base.connection.execute "UPDATE #{@node.class.table_name} SET active = #{params_data[:active]} WHERE id = #{@node.id}"
      else
        result = @node.update_attributes allowed_params
      end

      if result
        # Guardamos las cookies que usaremos después
        set_cookies @node.id, @node.active

        # Si el nodo es de tipo "main", notificamos al sistema de los cambios en sus variables y listas
        if @type == 'main'
          get_url_response "#{IVR_CONFIG['nodes']['main']['vars_system_url'][Rails.env]}/#{@node.id}"
          get_url_response "#{IVR_CONFIG['nodes']['main']['lists_system_url'][Rails.env]}/#{@node.id}/lists/#{@node.lists.map{ |x| x.id }.join(',')}"
        end

        # Cerramos la capa y actualizamos el gráfico
        close_div_and_compute_graph
      else
        render :action => :edit
      end
    end

    def delete
    end

    def destroy
      if @node.destroy
        # Si el proceso se ha completado, el seleccionado pasa a ser su padre
        set_cookies @node.parent_id, @node.active, (Ivr::Node.where(id: @node.parent_id).first).real_type
      end

      close_div_and_compute_graph
    end

    def disable
    end

    private

      def add_find
        # Obtenemos los datos del nodo
        node_view = Ivr::Node.where(id: params[:id]).first
        @node = node_view.data
        # Averiguamos el tipo
        @type = node_view.real_type
      end

      def add_extra_info
        # Datos comunes
        unless @type == 'main'
          @vars = @node.main_node.vars.map{ |x| { 'text' => x.name, 'value' => x.id } } unless @node.main_node.vars.blank?
          @tables = @node.main_node.tables.map{ |x| { 'text' => x.name, 'value' => x.id } } unless @node.main_node.tables.blank?
        end
        # Datos específicos
        case @type
          when 'main'
            @variable_types = IVR_CONFIG['nodes']['main']['vars'].rclone.map{ |k,v| { 'value' => k, 'text' => I18n.t(v) } }
          when 'audio'
            @audios = @node.audios.sort_by{ |x| x.order } unless @node.audios.blank?
          when 'transfer'
            get_nodes_with_status_data
            @destinations = @node.destinations.sort_by{ |x| x.order } unless @node.destinations.blank?
            @strategy = IVR_CONFIG['nodes']['transfer']['strategy'].rclone.map{ |k,v| { 'value' => k, 'text' => I18n.t(v) } }
            @destination_types = IVR_CONFIG['nodes']['transfer']['destinations']['types'].rclone.map{ |k,v| { 'value' => k, 'text' => I18n.t(v) } }
            if @node.main_node.vars.blank?
              @destination_types = @destination_types.delete_if{ |x| x['value'] == 'var' }
              @no_vars = true
            end
          when 'menu'
            @grammars = Libs::Grammar.where("users_id = #{session[:user]['data']['id']} OR users_id IS NULL").order('id DESC').to_a
            @node.related_options = Ivr::Option.where(ivr_menu_nodes_id: @node.id).to_a unless @node.grammar.blank? || not @node.options.blank?
            get_allowed_node_types 'menu'
          when 'data_entry'
            get_nodes_with_status_data
            @related_grammars = Array.new
            @node.grammars.each{ |x| @related_grammars.push x.id }
          when 'jump'
            find_tree
            spacetree_preferences
          when 'source_condition'
            get_nodes_with_status_data
            @source_modes = IVR_CONFIG['nodes']['source_condition']['source_modes'].rclone.map{ |k,v| { 'value' => k, 'text' => I18n.t(v) } }
          when 'schedule_condition'
            get_nodes_with_status_data
          when 'expression_condition'
            get_nodes_with_status_data
        end
        if %w(audio voicemail menu data_entry).include? @type
          @voices = IVR_CONFIG['nodes']['audio']['voices'].rclone.map{ |x| { 'value' => x['value'], 'text' => I18n.t(x['text']) } }
        end
      end

      def get_nodes_with_status_data
        get_allowed_node_types @type
        @node.children = @node.id.blank? ? Array.new : Ivr::Node.find(@node.id).children
      end

      def root_destroy
        # Si se trata del nodo principal, impedimos que alguien intente borrarlo
        render_error 403 if @type == 'main'
      end

      def add_find_parent
        # Si un nodo tiene varios hijos (estados), no se permite la inserción de ningún otro entre medias
        num_children = Ivr::Node.where(parent_id: params[:parent]).count unless params[:parent].blank?
        @parent = Ivr::Node.where(id: params[:parent]).first if not num_children.blank? && num_children < 2
        # Si el padré está en blanco o es de tipo "salto", mostramos un mensaje de error
        if @parent.blank? || @parent.real_type == 'jump'
          render_error 403
        else
          # En función del tipo del mismo, creamos la lista de nodos que se le pueden asociar
          get_allowed_node_types @parent.real_type
          # Agregamos también los datos del tipo de nodo y del árbol actual
          unless params[:type].blank?
            @type = params[:type]
            find_tree
          end
        end
      end

      def find_tree
        @tree = Ivr::Tree.where(id: params[:tree_id]).first
        render_error 403 unless session[:user]['data']['id'] == @tree.users_id
      end

      def new_object(attrs = nil)
        # Creamos el objeto según convenga (dependiendo del tipo)
        add_data_attrs = { :type => "#{params[:type]}_#{IVR_CONFIG['node_tables_sufix']}", :path => @parent.path }
        @node = Ivr::Node.new(add_data_attrs).data
        # Le agregamos los atributos si es que se nos han proporcionado
        @node.attributes = attrs unless attrs.blank?
      end

      def find_tree_id
        @id_tree = params[:tree_id].blank? ? @node.main_node.tree.id : params[:tree_id]
      end

      def set_cookies(id, active, type = params[:type])
        find_tree_id
        cookies["st_selected_node_#{@id_tree}".to_sym] = "#{id.to_s}##{type}##{active.to_s}"
        cookies["st_reload_#{@id_tree}".to_sym] = true
      end

      def unset_reload_cookie
        find_tree_id
        cookies["st_reload_#{@id_tree}".to_sym] = false
      end

      def close_div_and_compute_graph
        render text: "#{WEBO_CONFIG['exec_response_flag']}close_div('lib'); close_div('node'); compute_graph();"
      end

      def render_new_form
        add_extra_info unless @node.blank?
        render 'ivr/nodes/new/form'
      end

      def get_allowed_node_types(node_type)
        available_nodes = IVR_CONFIG['nodes']['types']
        available_nodes = available_nodes.rclone.delete_if{ |k,v| IVR_CONFIG['disabled_features']['nodes'].include? k } unless %w(development test).include? Rails.env
        @available_nodes = Array.new
        available_nodes.keys.each do |n|
          if available_nodes[node_type].blank? || not available_nodes[node_type].include? n
            @available_nodes.push({
              :id => n,
              :name => I18n.t("ivr.nodes.types.list.#{n}")
            })
          end
        end
        # La inserción de un nodo "salto" en medio del árbol no está permitida
        @available_nodes.delete_if{ |x| x[:id] == 'jump' } unless @parent.blank? || @parent.children.blank?
        # Si no hay ninguna variable configurada en el nodo principal, impedimos la creación de un nodo de tipo "Entrada de datos"
        @available_nodes.delete_if{ |x| x[:id] == 'data_entry' } if Ivr::Tree.find(params[:tree_id]).main_node.vars.blank?
        # Ordenamos el listado alfabéticamente
        @available_nodes.sort!{ |x,y| x[:name] <=> y[:name] }
      end

      def allowed_params
        case @type
          when 'voicemail'
            params.require(:voicemail_node).permit(
              :name,
              :timeout,
              :maxtime,
              :bargein,
              :beep,
              :send_now,
              :text,
              :voice,
              :email_from,
              :email_subject,
              :email_message,
              :prompt_data => %w(libs_audios_id text tts_voice),
              :confirm_data => %w(libs_audios_id text tts_voice),
              :no_match_data => %w(libs_audios_id text tts_voice)
            ).tap do |whitelisted|
              whitelisted[:related_accounts] = params[:voicemail_node][:related_accounts]
            end
          when 'integration'
            params.require(:integration_node).permit(
              :name,
              :type,
              :content,
              :url
            )
          when 'expression_condition'
            params.require(:expression_condition_node).permit(
              :name,
              :expression,
              :ok_node,
              :error_node
            )
          when 'schedule_condition'
            params.require(:schedule_condition_node).permit(
              :name,
              :libs_schedules_id,
              :ok_node,
              :error_node
            )
          when 'source_condition'
            params.require(:source_condition_node).permit(
              :name,
              :ok_node,
              :error_node
            ).tap do |whitelisted|
              whitelisted[:related_sources] = params[:source_condition_node][:related_sources]
            end
          when 'data_entry'
            params.require(:data_entry_node).permit(
              :name,
              :timeout,
              :times,
              :ivr_variables_id,
              :bargein,
              :beep,
              :asr,
              :ok_node,
              :error_node
            ).tap do |whitelisted|
              whitelisted[:prompt] = params[:data_entry_node][:prompt]
              whitelisted[:no_match] = params[:data_entry_node][:no_match]
              whitelisted[:disconnect] = params[:data_entry_node][:disconnect]
              whitelisted[:related_grammars] = params[:data_entry_node][:related_grammars]
            end
          when 'audio'
            params.require(:audio_node).permit(
              :name,
              :ok_node,
              :error_node
            ).tap do |whitelisted|
              whitelisted[:related_audios] = params[:audio_node][:related_audios]
            end
          when 'menu'
            params.require(:menu_node).permit(
              :name,
              :timeout,
              :times,
              :ivr_variables_id,
              :bargein,
              :asr,
              :grammar
            ).tap do |whitelisted|
              whitelisted[:no_match] = params[:menu_node][:no_match]
              whitelisted[:prompt] = params[:menu_node][:prompt]
              whitelisted[:related_options] = params[:menu_node][:related_options]
            end
          when 'main'
            params.require(:main_node).permit(
              :name,
              :lists_type
            ).tap do |whitelisted|
              whitelisted[:related_vars] = params[:main_node][:related_vars]
              whitelisted[:related_tables] = params[:main_node][:related_tables]
              whitelisted[:related_lists] = params[:main_node][:related_lists]
            end
          when 'jump'
            params.require(:jump_node).permit(
              :name,
              :ivr_nodes_id,
              :ivr_nodes_name
            )
          when 'transfer'
            params.require(:transfer_node).permit(
              :name,
              :caller_id,
              :maxtime,
              :strategy,
              :ok_node,
              :error_node
            ).tap do |whitelisted|
              whitelisted[:related_destinations] = params[:transfer_node][:related_destinations]
            end
        end
      end
  end
end
