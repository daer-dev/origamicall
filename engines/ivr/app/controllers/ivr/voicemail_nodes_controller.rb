module Ivr
  class VoicemailNodesController < IvrController
    def send_audio
      # Comprobamos que la petición tenga todos los campos requeridos
      fields = %w(emails node number timestamp from subject message token)

      if (params.keys & fields).sort == fields.sort
        params[:emails].split(',').each do |email_to|
          if Ivr::VoicemailNodeMailer.email(params[:node], params[:number], params[:timestamp], params[:from], email_to, params[:subject], params[:message], params[:token]).deliver_now
            return render text: 250
          else
            render text: 554
          end
        end
      else
        render text: 400
      end
    end

    def download_audio
      audio = Ivr::VoicemailRecord.where(token: params[:token]).first

      if audio.blank?
        render_error 404
      else
        download_file "#{IVR_CONFIG['nodes']['voicemail']['audios_url']}/#{audio.file}.mp3"
      end
    end
  end
end