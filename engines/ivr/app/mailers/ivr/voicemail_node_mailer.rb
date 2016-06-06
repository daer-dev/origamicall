module Ivr
  class VoicemailNodeMailer < ActionMailer::Base
    def email(node, number, timestamp, from, to, subject, message, token)
      @node = node
      @number = number
      @timestamp = ApplicationController.helpers.format_timestamp(Time.at(timestamp.to_i).to_datetime)
      @text = message
      @link = download_audio_voicemail_nodes_url(token: token)

      mail({
        template_path: 'ivr/nodes/voicemail',
        from: from,
        to: to,
        subject: subject
      })
    end
  end
end