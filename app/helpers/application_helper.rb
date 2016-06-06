module ApplicationHelper
  include DateTimeHelper
  include FormHelper

  def render_error(status, raw_message = true)
    if Rails.env == 'production' || @response.blank? || @exception.blank?
      status = "status_#{status}" if status.is_a? Integer
      status = 'status_500' unless i18n_data[:messages][:error].include? status.to_sym
      title = I18n.t("messages.error.#{status}.title")
      message = I18n.t("messages.error.#{status}.text")
    else
      title = "#{@response} (#{status})"
      message = @exception
    end

    render 'shared/errors', locals: { title: title, message: message, raw_message: raw_message }
  end

  def i18n_data
    I18n.backend.send(:init_translations) unless I18n.backend.initialized?
    I18n.backend.send(:translations)[I18n.locale]
  end

  def engine_name
    params[:controller].split('/').first
  end

  def engine_config
    begin
      eval("#{engine_name.upcase}_CONFIG")
    rescue
      Hash.new
    end
  end

  def locale_to_js(mode = :all)
    mode = mode.to_sym
    modes_array = case mode
      when :all then [ 'shared', params[:controller] ]
      when :shared then [ 'shared' ]
      when :controller then [ params[:controller] ]
    end
    js_code = mode == :all ? { :name => I18n.locale } : Hash.new

    [ WEBO_CONFIG, engine_config ].each do |config|
      if config.include? 'locale' && config['locale'].include? 'fields_to_js'
        config['locale']['fields_to_js'].each do |controller,list|
          if modes_array.include? controller
            list.each do |text|
              trad = I18n.t(text)
              trad = I18n.t(text).delete_if{ |x| x.nil? } if I18n.t(text).is_a? Array
              js_code[text] = trad
            end
          end
        end
      end
    end

    data_to_js 'locale', js_code unless js_code.blank?
  end

  def flag(locale)
    flag = {
      'es_ES' => 'es',
      'en_EN' => 'gb'
    }
    flag[locale.to_s]
  end

  def convert_audios(paths, extensions)
    unless extensions.blank? || paths.blank?
      # Si en vez de un array de paths/extensiones recibimos un solo path/extensión (string), lo convertimos
      paths = [ paths ] unless paths.is_a?(Array)
      extensions = [ extensions ] unless extensions.is_a?(Array)
      # Seteamos las variables que usaremos más adelante
      cmd = Array.new
      del = Array.new
      files = Array.new
      result = true
      # Recorremos los paths ignorando los que estén en blanco, no existan o no sean del tipo que buscamos
      paths.each do |path|
        unless path.blank?
          extension_origen = File.basename(path).split('.', 2).last.downcase
          if path.is_a? String && File.exists? path && %w(mp3 wav).include? extension_origen
            resto = path.gsub(".#{extension_origen}", String.new)
            # En vez de trabajar sobre el original, lo haremos sobre una copia
            temp_path = path.gsub(".#{extension_origen}", "_tmp.#{extension_origen}")
            FileUtils.copy(path, temp_path)
            del.push(temp_path)
            # Recorremos el array de extensiones que queremos obtener y ejecutamos el comando correspondiente para cada una de ellas
            del.push(path) unless extensions.include? extension_origen
            extensions.each do |ext|
              files.push "#{resto}.#{ext}"
              cmd.push WEBO_CONFIG['commands']['to_' + ext].gsub('{{foo}}', temp_path).gsub('{{bar}}', resto)
            end
          end
        end
      end
      # Ejecutamos los comandos "sox" bajo "system". Si falla alguno, abortamos el proceso y eliminamos los archivos generados
      cmd.each do |c|
        unless system c
          del += files
          Rails.logger.error "system #{c}"
          result = false
          break
        end
      end
      # Borramos lo que sea necesario
      del.each do |d|
        if FileTest.exists? d
          Rails.logger.error "File.delete(#{d})" unless File.delete(d)
        end
      end
    end
    result
  end

  def js_redirect_to(path)
    path = "##{path}"
    path = "/#{engine_name}?window#{path}" if params.include? :window

    respond_to do |format|
      format.js { render :js => view_context.javascript_tag("js_redirect('#{path}');") }
    end
  end

  def hlink_to(text = nil, url = nil, html_options = nil, &block)
    html_options, url, text = url, text, capture(&block) if block_given?
    link_to(text, "##{url}", html_options)
  end

  def link_in_window_to(text = nil, url = nil, on_close = nil, html_options = nil, &block)
    html_options, url, text = url, text, capture(&block) if block_given?
    url = "javascript:open_modal([ '#{url}#{url.include?('?') ? '&' : '?'}window' ]#{(", '" + on_close + "'") unless on_close.blank?});"
    link_to(text, url, html_options)
  end

  def player(path)
    unless path.blank? || path[-4..-1] != '.mp3'
      raw "
        <audio controls>
          <source src=\"#{path}\" type=\"audio/mpeg\" />
          <a href=\"#{path}\">#{I18n.t('actions.play')}</a>
        </audio>"
    end
  end

  def tooltip(text, title = nil, content = icon('info-circle'), data_placement = 'right')
    raw "<span rel=\"popover\" data-trigger=\"hover click\" data-placement=\"#{data_placement}\" data-original-title=\"#{title}\" data-content=\"#{text}\" data-html=\"true\">#{content}</span>"
  end

  def data_to_js(var_name, data, tags = true)
    # Comprobamos si es necesario incluir el nombre de la variable
    if var_name.blank?
      code = data.to_json
    else
      code = "if(typeof(#{var_name}) == 'undefined') { var #{var_name} = Object.create(null); }\n"
      data.each do |k,v|
        code += "#{var_name}['#{k}'] = #{v.to_json}; "
      end
    end
    # Devolvemos el resultado, con o sin tags
    tags ? javascript_tag(code) : code
  end

  def get_url_response(url, url_params = nil, method = :get)
    begin
      Rails.logger.info "get_url_response #{url}, #{url_params}, #{method}"
      result = if method == :get
        url_params_string = url_params.blank? ? String.new : "?#{url_params.map{|k,v| "#{k}=#{v}"}.join('&')}"
        Net::HTTP.get_response URI.parse("#{url}#{url_params_string}")
      elsif method == :post
        Net::HTTP.post_form(URI.parse(url), url_params).body
      else
        false
      end
    rescue Exception => e
      Rails.logger.info "ERROR: #{e}"
    end
  end

  def download_file(path)
    path = Rails.public_path.join(path)

    begin
      send_file path
    rescue
      Rails.logger.error "send_file #{path}"
      render_error 404
    end
  end

  def feature_disabled?(feature_name)
    WEBO_CONFIG.include?('disabled_features') && WEBO_CONFIG['disabled_features'].include?(feature_name) && not %w(development test).include?(Rails.env)
  end
end
