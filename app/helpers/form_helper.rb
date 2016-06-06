module FormHelper
  def form(record, options = Hash.new, &proc)
    @record = record
    raw form_for(record, options, &proc)
  end

  def options_from_hash_for_select(collection, value_method = :value, text_method = :text, selected = nil, empty_option = false, sort_by_value = true)
    collection = Array.new if collection.blank?
    # Recorremos las opciones, montando el listado de nombres y valores
    if collection[0].is_a?(String)
      temp = Array.new
      collection.each do |c|
        temp.push({ :text => c, :value => c })
      end
      collection = temp
    end
    options = collection.map do |element|
      begin
        a = [ eval("element.#{text_method}.to_s"), eval("element.#{value_method}.to_s") ]
      rescue
        a = [ element[text_method.to_s].to_s, element[value_method.to_s].to_s ]
        a = [ element[text_method.to_sym].to_s, element[value_method.to_sym].to_s ] if a.delete_if{ |x| x.blank? }.blank?
      end
      a
    end
    # Ordenamos las opciones por su valor
    if sort_by_value
      options_no_value = options.select{ |x| x[1].blank? }.each{ |x| x.push String.new if x.length == 1 }
      options = options_no_value + (options.delete_if{ |x| x[1].blank? }.sort_by{ |x| x[1] })
    end
    # Si así se ha especificado, agregamos una opción en blanco
    if empty_option != false
      empty_option = empty_option == true ? I18n.t('misc.empty_option_text') : empty_option
      options = [ [ empty_option, nil ] ] + options
    end
    # Generamos las opciones
    options_for_select(options, selected.to_s)
  end

  def fields_errors(list)
    # Eliminamos los errores duplicados generados por Paperclip
    list = list.delete_if{ |x| x = x.to_s; (x.include? '_content_type' || x.include? '_file_size') && list.include? x.split('_')[0].to_sym }
    # Seguimos con el proceso
    code = String.new
    list.each do |k,v|
      unless v.blank?
        if k == :base
          v.each do |x|
            code += "<li>#{x}</li>"
          end
        else
          if v.length == 1
            message = v[0]
          else
            sub_messages = String.new
            v.each do |x|
              sub_messages += "<li>#{x}</li>"
            end
            message = "<ul>#{sub_messages}</ul>"
          end

          i18n_controller = params[:controller].gsub('/', '__').to_sym
          i18n_controller_data = i18n_data[:fields][:controllers][i18n_controller]

          if i18n_controller_data.is_a? Hash && i18n_controller_data.include? k.to_sym
            field = I18n.t("fields.controllers.#{i18n_controller}.#{k}")
          elsif i18n_data[:fields][:shared].include? k.to_sym
            field = I18n.t("fields.shared.#{k}")
          else
            field = k.to_s.gsub('_', ' ').capitalize
          end

          code += "<li><strong>#{field}</strong>: #{message}</li>"
        end
      end
    end
    raw code
  end

  def auto_label_for(f, field = String.new, html_options = nil)
    unless field.blank?
      field = field.to_s.gsub('[', String.new).gsub(']', '_').gsub('__', '_').to_sym
      i18n_controller = params[:controller].gsub('/', '__').to_sym

      if i18n_data[:fields].include? :controllers && i18n_data[:fields][:controllers].include? i18n_controller && i18n_data[:fields][:controllers][i18n_controller].is_a? Hash && i18n_data[:fields][:controllers][i18n_controller].include? field
        label = I18n.t("fields.controllers.#{i18n_controller}.#{field}")
      elsif i18n_data[:fields][:shared].include? field
        label = I18n.t("fields.shared.#{field}")
      end
      label = raw label
      html_options = Hash.new if html_options.blank?
      begin
        f.label field, label, html_options
      rescue
        label_tag field, label, html_options
      end
    end
  end

  def smart_text_field(f, name, icon_name = 'align-justify', html_options = Hash.new)
    field = if name.is_a? Array
      input_name = name[0].to_s

      input_name = if input_name.include? '['
        "#{f.object_name}#{input_name}"
      else
        "#{f.object_name}[#{input_name}]"
      end

      text_field_tag input_name, name[1], html_options
    else
      f.text_field name, html_options
    end

    raw "
      <label class=\"input\">
        <span class=\"hidden-xs\">#{icon icon_name, String.new, class: 'icon-append'}</span>
        #{field}
      </label>"
  end

  def smart_select_field(f, name, options, html_options = Hash.new)
    input_name = if f.blank?
      name
    else
      if name.to_s.include? '['
        "#{f.object_name}#{name.to_s}"
      else
        "#{f.object_name}[#{name.to_s}]"
      end
    end

    raw "
      <label class=\"select\">
        #{select_tag input_name, options, html_options}
        <i></i>
      </label>"
  end

  def smart_file_field(f, name, html_options = Hash.new)
    html_options[:readonly] = true

    raw "
      <label class=\"input input-file\">
        <div class=\"button\">#{f.file_field name, :onchange => 'this.parentNode.nextSibling.value = this.value'}#{I18n.t('actions.select')}</div>#{text_field_tag (name.to_s + '_file_name'), String.new, html_options}
      </label>"
  end

  def smart_checkbox(f, name, html_options = Hash.new)
    if name.is_a? Array
      name[0] = name[0].to_s

      input_name = if name[0].include? '['
        "#{f.object_name}#{name[0]}"
      else
        "#{f.object_name}[#{name[0]}]"
      end

      new_name = raw "
        #{check_box_tag input_name, name[1], name[2], html_options}
        <i></i>"
      new_name += raw("<span>#{name[3]}</span>") unless name[3].blank?

      result = label_tag input_name.gsub('[', '_').gsub(']', String.new), new_name, class: 'checkbox'
    else
      label_data = auto_label_for f, name
      open_label_tag = "#{label_data.gsub('</label>', String.new).gsub('>', ' class="checkbox">').split('>')[0]}>"
      label_text = label_data.split('>')[1].gsub('</label', String.new)

      result = raw "
        #{open_label_tag}
          #{f.check_box name, html_options}
          <i></i>
          <span>#{label_text}</span>
        </label>"
    end

    result
  end

  def smart_radio(f, name, value, text, html_options = Hash.new)
    raw "
      <label class=\"radio\">
        #{[ TrueClass, FalseClass ].include?(f.class) ? (radio_button_tag name, value, f) : (f.radio_button name, value, html_options)}
        <i></i>
        <span>#{text}</span>
      </label>"
  end

  def smart_textarea(f, name, html_options = Hash.new)
    field = if name.is_a? Array
      name[0] = name[0].to_s

      input_name = if name[0].include? '['
        "#{f.object_name}#{name[0]}"
      else
        "#{f.object_name}[#{name[0]}]"
      end

      text_area_tag input_name, name[1], html_options
    else
      f.text_area name, html_options
    end

    raw "
      <label class=\"textarea\">
        #{field}
      </label>"
  end
end
