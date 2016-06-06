module Ivr
  class VoicemailRecord < ActiveRecord::Base
    self.table_name = 'ivr.voicemail_records'

    belongs_to :node, :class_name => 'Ivr::Node', :foreign_key => 'ivr_nodes_id'
  end
end