# ÁRBOL DE EJEMPLO

user_id = User.first.id
mobile_phone = '600000000'
fixed_line_phone = '910000000'
tts_voice = IVR_CONFIG['nodes']['audio']['voices'][0]['value']

ActiveRecord::Base.transaction do
  # Audio (guardándolo saltándonos las validaciones para que no detecte que no estamos enviando ningún archivo)
  audio = Libs::Audio.new({
    :name => 'Audio 1',
    :product => 'ivr',
    :users_id => user_id
  })
  audio.save(validate: false)

  # Horario
  schedule = Libs::Schedule.create!({
    :name => 'Horario 1',
    :product => 'ivr',
    :d1_1_1 => '07:00',
    :d1_1_2 => '14:00',
    :d1_2_1 => '17:00',
    :d1_2_2 => '20:00',
    :d2_1_1 => '07:00',
    :d2_1_2 => '14:00',
    :d2_2_1 => '17:00',
    :d2_2_2 => '20:00',
    :holidays_list => '19/02/2015,20/02/2015',
    :users_id => user_id
  })

  # Lista
  list = Libs::List.create!({
    :name => 'Lista 1',
    :product => 'ivr',
    :type => 'white',
    :users_id => user_id
  })
  [ mobile_phone, fixed_line_phone ].each do |contact|
    Libs::Contact.create!({
      :libs_lists_id => list.id,
      :phone_number => contact
    })
  end

  # Tabla
  table = Libs::Table.create!({
    :name => 'Tabla 1',
    :product => 'ivr',
    :related_rows => {
      'r_1' => {
        'name' => 'Nombre 1',
        'value' => 'Valor 1'
      },
      'r_2' => {
        'name' => 'Nombre 2',
        'value' => 'Valor 2'
      }
    },
    :users_id => user_id
  })

  # Árbol, nodo principal y servicios
  tree = Ivr::Tree.create!({
    :name => 'Árbol',
    :related_services => {
      's_1' => '1'
    },
    :users_id => user_id
  })
  tree.main_node.update_attributes({
    :related_vars => {
      'v_1' => {
        'name' => 'MOVIL',
        'value' => mobile_phone,
        'type' => 'session'
      },
      'v_2' => {
        'name' => 'FIJO',
        'value' => fixed_line_phone,
        'type' => 'session'
      }
    },
    :related_tables => {
      'group_' => {
        "elem_#{table.id}" => table.id
      }
    },
    :lists_type => 'white',
    :related_lists => {
      'group_white' => {
        "elem_#{list.id}" => list.id
      }
    }
  })

  # Nodo Condición de Origen
  source_condition_node = Ivr::SourceConditionNode.create!({
    :name => 'C. Origen',
    :related_sources => {
      's_1' => {
        'mode' => 'starts',
        'phone_number' => '6'
      }
    },
    :ok_node => 'audio',
    :error_node => 'audio',
    :parent_id => tree.main_node.id
  })
  # Estados
  audio_node_1 = source_condition_node.simple_children.select{ |x| x.status == true }[0].data
  audio_node_1.update_attributes({
    :name => 'Audio 1',
    :related_audios => {
      'a_1' => {
        'order' => '1',
        'libs_audios_id' => String.new,
        'text' => 'Hola, este es un audio fijo de bienvenida',
        'tts_voice' => tts_voice
      },
      'a_2' => {
        'order' => '2',
        'libs_audios_id' => String.new,
        'text' => 'Tu número de móvil es el ${MOVIL}',
        'tts_voice' => tts_voice
      },
      'a_2' => {
        'order' => '3',
        'libs_audios_id' => String.new,
        'text' => 'Y tu número fijo, el ${FIJO}',
        'tts_voice' => tts_voice
      }
    }
  })
  source_condition_node.simple_children.select{ |x| x.status == false }[0].data.update_attributes({
    :name => 'Audio 2',
    :related_audios => {
      'a_1' => {
        'order' => '1',
        'libs_audios_id' => String.new,
        'text' => 'Origen no permitido',
        'tts_voice' => tts_voice
      }
    }
  })

  # Nodo Menu (como hijo del audio del estado OK del anterior)
  menu_node = Ivr::MenuNode.create!({
    :name => 'Menu 1',
    :asr => false,
    :bargein => true,
    :maxlen => '3',
    :timeout => '5',
    :times => '3',
    :ivr_variables_id => String.new,
    :prompt => {
      'libs_audios_id' => String.new,
      'text' => 'Presione 1 para departamento comercial, 2 para departamento técnico, 3 para departamento de contabilidad',
      'tts_voice' => tts_voice
    },
    :no_match => {
      'libs_audios_id' => audio.id,
      'text' => String.new,
      'tts_voice' => String.new
    },
    :related_options => {
      'o_1' => {
        'type' => 'audio',
        'default' => false,
        'dtmf' => '1'
      },
      'o_2' => {
        'type' => 'audio',
        'default' => false,
        'dtmf' => '2'
      },
      'o_3' => {
        'type' => 'audio',
        'default' => false,
        'dtmf' => '3'
      },
      'o_4' => {
        'type' => 'jump',
        'default' => true,
        'dtmf' => String.new
      },
    },
    :parent_id => audio_node_1.id
  })
  # Opciones
  menu_node.options.each do |option|
    case option.dtmf
      when '1'
        # Nodo Audio (DTMF 1)
        audio_node_3 = Ivr::AudioNode.where(id: option.node.id).first
        audio_node_3.update_attributes({
          :name => 'Comercial',
          :related_audios => {
            'a_1' => {
              'order' => '1',
              'libs_audios_id' => String.new,
              'text' => 'Bienvenido al departamento comercial',
              'tts_voice' => tts_voice
            }
          }
        })
        @audio_node_3 = audio_node_3
      when '2'
        # Nodo Audio (DTMF 2)
        audio_node_4 = Ivr::AudioNode.where(id: option.node.id).first
        audio_node_4.update_attributes({
          :name => 'Técnicos',
          :related_audios => {
            'a_1' => {
              'order' => '1',
              'libs_audios_id' => String.new,
              'text' => 'Bienvenido al departamento técnico',
              'tts_voice' => tts_voice
            }
          }
        })
      when '3'
        # Nodo Audio (DTMF 3)
        audio_node_5 = Ivr::AudioNode.where(id: option.node.id).first
        audio_node_5.update_attributes({
          :name => 'Contabilidad',
          :related_audios => {
            'a_1' => {
              'order' => '1',
              'libs_audios_id' => String.new,
              'text' => 'Bienvenido al departamento de contabilidad',
              'tts_voice' => tts_voice
            }
          }
        })
      else
        # Nodo Audio (sin DTMF, opción por defecto)
        jump_node = Ivr::JumpNode.where(id: option.node.id).first
        jump_node.update_attributes({
          :name => 'Inicio',
          :ivr_nodes_id => audio_node_1.id
        })
      end
  end

  # Nodo Condición Horaria (a continuación del audio que figura como primera opción del menu)
  schedule_condition_node = Ivr::ScheduleConditionNode.create!({
    :name => 'C. Horaria 1',
    :libs_schedules_id => schedule.id,
    :parent_id => @audio_node_3.id,
    :ok_node => 'audio',
    :error_node => 'audio'
  })
  # Estados
  schedule_condition_node.simple_children.select{ |x| x.status == true }[0].data.update_attributes({
    :name => 'Audio 6',
    :related_audios => {
      'a_1' => {
        'order' => '1',
        'libs_audios_id' => String.new,
        'text' => 'Estamos contactando con el responsable del departamento comercial, en breves instantes atenderemos su llamada',
        'tts_voice' => tts_voice
      }
    }
  })
  schedule_condition_node.simple_children.select{ |x| x.status == false }[0].data.update_attributes({
    :name => 'Audio 7',
    :related_audios => {
      'a_1' => {
        'order' => '1',
        'libs_audios_id' => String.new,
        'text' => 'Se encuentra fuera de horario de oficina. Llame más tarde, por favor',
        'tts_voice' => tts_voice
      }
    }
  })
end