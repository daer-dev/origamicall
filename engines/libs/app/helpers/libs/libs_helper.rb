module Libs
  module LibsHelper
    def external_engine
      name = request.fullpath.split('/')[1]
      name == engine_name ? false : name
    end

    def get_allowed_libs
      libs = Array.new
      session[:user]['products'].each do |product|
        libs += LIBS_CONFIG['products_libs'][product.to_s]
      end
      libs.uniq!
      libs
    end

    def redirect(lib, id, name, redir_path)
      if params.include? :ajax_loaded
        singularized_lib = lib.to_s.singularize
        group = params[singularized_lib][:type].blank? ? String.new : params[singularized_lib][:type]
        render text: "#{WEBO_CONFIG['exec_response_flag']}update_libs('#{lib}','#{id}','#{name}', '#{group}'); close_div('lib');#{('if(typeof(load_grammar_options) == "function") { load_grammar_options(' + id.to_s + ', true); }') if lib == :grammars}"
      else
        js_redirect_to redir_path
      end
    end

    def get_string(str, mode)
      if %w(list_type account_type).include? mode
        data = Hash.new
        @type.each do |x|
          data[x['value']] = x['text']
        end
      elsif mode == 'list_type_icon'
        data = {
        'white' => 'check',
        'black' => 'ban',
        'vip' => 'star'
        }
      end
      data[str]
    end

    def libs_data(lib, product = nil)
      product = product.to_s unless product.blank?
      case lib
        when 'grammars'
          {
            'list' => Libs::Grammar.where('(users_id = ? OR users_id IS NULL) AND (product = ? OR product IS NULL)', session[:user]['data']['id'], product).order('id DESC').to_a,
            'links' => {
              'new' => libs.new_grammar_path,
              'edit' => libs.edit_grammar_path(0)
            }
          }
        when 'audios'
          {
            'list' => Libs::Audio.where('(users_id = ? OR users_id IS NULL) AND (product = ? OR product IS NULL)', session[:user]['data']['id'], product).order('id DESC').to_a,
            'links' => {
              'new' => libs.new_audio_path,
              'edit' => libs.edit_audio_path(0)
            }
          }
        when 'destinations'
          {
            'list' => Libs::Destination.where('(users_id = ? OR users_id IS NULL) AND (product = ? OR product IS NULL)', session[:user]['data']['id'], product).order('id DESC').to_a,
            'links' => {
              'new' => libs.new_destination_path,
              'edit' => libs.edit_destination_path(0)
            }
          }
        when 'schedules'
          {
            'list' => Libs::Schedule.where('(users_id = ? OR users_id IS NULL) AND (product = ? OR product IS NULL)', session[:user]['data']['id'], product).order('id DESC').to_a,
            'links' => {
              'new' => libs.new_schedule_path,
              'edit' => libs.edit_schedule_path(0)
            }
          }
        when 'lists'
          {
            'list' => {
              'white' => [
                'libs.lists.types.white',
                Libs::List.where('type = ? AND (users_id = ? OR users_id IS NULL) AND (product = ? OR product IS NULL)', 'white', session[:user]['data']['id'], product).order('id DESC').to_a
              ],
              'black' => [
                'libs.lists.types.black',
                Libs::List.where('type = ? AND (users_id = ? OR users_id IS NULL) AND (product = ? OR product IS NULL)', 'black', session[:user]['data']['id'], product).order('id DESC').to_a
              ],
              'vip' => [
                'libs.lists.types.vip',
                Libs::List.where('type = ? AND (users_id = ? OR users_id IS NULL) AND (product = ? OR product IS NULL)', 'vip', session[:user]['data']['id'], product).order('id DESC').to_a
              ]
            },
            'links' => {
              'new' => libs.new_list_path,
              'edit' => libs.edit_list_path(0)
            }
          }
        when 'tables'
          {
            'list' => Libs::Table.where('(users_id = ? OR users_id IS NULL) AND (product = ? OR product IS NULL)', session[:user]['data']['id'], product).order('id DESC').to_a,
            'links' => {
              'new' => libs.new_table_path,
              'edit' => libs.edit_table_path(0)
            }
          }
        when 'accounts'
          {
            'list' => Libs::Account.where('(users_id = ? OR users_id IS NULL) AND (product = ? OR product IS NULL)', session[:user]['data']['id'], product).order('id DESC').to_a,
            'links' => {
              'new' => libs.new_account_path,
              'edit' => libs.edit_account_path(0)
            }
          }
        end
    end

    def lib(f, type, field, selected_val = nil, buttons = true, select_properties = Hash.new)
      data = libs_data type.to_s, engine_name
      field = field.to_s

      unless data.blank?
        # Si el valor seleccionado está en los parámetros, lo rescatamos y obviamos el que se nos ha proporcionado
        selected_val = nil if selected_val == String.new
        begin
          param_value = eval "params['#{field.split('[')[0]}']#{field.split('[')[1..-1].map{ |x| "['" + x }.join.gsub(']', "']")}"
          selected_val = eval param_value if param_value
        rescue
        end

        list = [ { :id => nil, :name => I18n.t('misc.empty_option_text') } ] + data['list']
        edit_path = data['links']['edit']
        edit_path.gsub!('0', selected_val.to_s) unless selected_val.blank?
        edit_class = 'btn btn-default btn-xs edit'
        edit_class += ' hidden-block' if selected_val.blank?
        div_id = field.gsub('[', '_').gsub(']', String.new)
        div_id = div_id[1..-1] if div_id.first == '_'
        select_properties_onchange = select_properties.include?(:onchange) ? "#{select_properties[:onchange]}#{';' unless select_properties[:onchange].include? ';'}" : String.new
        select_properties[:onchange] = "#{select_properties_onchange}change_edit_libs('#{div_id}');"

        code = "
        <div id=\"#{div_id}\" class=\"lib lib_#{type}\">
          #{smart_select_field(f, field, options_from_hash_for_select(list, :id, :name, selected_val), select_properties)}"
          if buttons
            code += "
             #{link_to I18n.t('actions.edit'), edit_path, :onclick => "javascript:load_in_div(this.href + '?ajax_loaded', 'lib');return false;", :class => edit_class}
             #{link_to I18n.t('misc.new'), data['links']['new'], :onclick => "javascript:load_in_div(this.href + '?ajax_loaded', 'lib');return false;", :class => 'btn btn-default btn-xs'}"
          end
        code += '</div>'

        raw code
      end
    end

    def multiple_lib(f, lib, field, selected_group_field, selected_group, selected_vals, except = Array.new, disabled_option = false, buttons = true)
      data = libs_data lib.to_s, engine_name

      unless data.blank?
        # Si sólo se ha especificado un índice excluido, se mete en un array
        except = [ except ] unless except.is_a? Array

        # Procesamos el listado de elementos
        list = Hash.new
        titles = Hash.new
        data['list'] = { String.new => [ String.new, data['list'] ] } unless data['list'].is_a? Hash
        data['list'].each do |k,v|
          # Obviamos todos los que tengan el índice en "except"
          unless except.include? k
            # Separamos el listado de datos de los títulos
            list[k] = v[1]
            titles[k] = v[0].blank? ? '&nbsp;' : I18n.t(v[0])
          end
        end

        # Si se quiere mostrar la opción "desactivado", la agregamos al hash "titles"
        titles[String.new] = I18n.t('misc.disabled') if disabled_option

        selected_group_field_name = "#{selected_group_field.to_s}_#{(rand * 1000000000000).round.to_s(16)}"
        code = "<div id=\"lib_#{selected_group_field_name}\" class=\"multiple_lib lib_#{lib}\">"

        # Escribimos el listado de títulos
        code += "
          #{hidden_field_tag (lib.to_s + '_field'), ('[' + field.to_s + ']')}

          <div class=\"multiple_lib_option\">
            #{render 'libs/shared/multiple_lib_option', f: f, id: '{{ID}}', name: '{{NAME}}', field: '{{FIELD_NAME}}', link: libs.edit_audio_path(0).gsub('audios', '{{LIB}}').gsub('0', '{{ID}}'), checked: true, buttons: true, edit_button: true}
          </div>

          <span class=\"title\">"
            if titles.keys.length == 1
              code += titles.values[0]
            else
              titles.each do |k,v|
                toggle_code = [ "#lib_#{selected_group_field_name} .group_#{k}" ].concat(titles.keys.map!{ |x| "#lib_#{selected_group_field_name} .group_#{x}" unless x == k }.compact).inspect.gsub(', ', ',')
                radio_button_code = "smart_radio f, selected_group_field, k, v"
                radio_button_code += ", :onclick => 'javascript:show_and_hide(#{toggle_code});'" unless k == 'disabled'
                code += eval radio_button_code
              end
            end
          code += '</span>'

        # Montamos el bloque de elementos de cada grupo
        list.each do |k,v|
          code += "
          <div class=\"group group_#{k}#{' hidden-block' unless k == selected_group || titles.keys.length == 1}\">"
            code += "#{link_to I18n.t('misc.new'), data['links']['new'] + (k.blank? ? String.new : ('?group=' + k)), :onclick => "javascript:load_in_div(this.href + '" + (k.blank? ? '?' : '&') + "ajax_loaded', 'lib');return false;", :class => 'btn btn-default btn-xs'}" if buttons
            code += "
            <ul class=\"scroll\">"
              if v.blank?
                code += "<li class=\"empty\">#{I18n.t('messages.error.no_results')}</li>"
              else
                v.each do |l|
                  code += render 'libs/shared/multiple_lib_option', f: f, id: l.id, name: l.name, field: ('[' + field.to_s + '][group_' + k + '][elem_' + l.id.to_s + ']'), checked: selected_vals.include?(l), link: data['links']['edit'].gsub('0', l.id.to_s), buttons: buttons, users_id: l.users_id
                end
              end
            code += '
            </ul>
          </div>'
        end

        raw code += '</div>'
      end
    end
  end
end
