module Ivr
  class VoicemailNode < ActiveRecord::Base
    self.table_name = 'ivr.voicemail_nodes'

    # Evitamos que Rails utilice "type" como columna de herencia
    self.inheritance_column = nil

    has_one :option, :class_name => 'Ivr::Option', :foreign_key => 'ivr_nodes_id', :dependent => :destroy
    has_many :nodes_accounts, :class_name => 'Ivr::NodeAccount', :foreign_key => 'ivr_nodes_id', :dependent => :destroy
    has_many :accounts, :through => :nodes_accounts
    has_many :audios, :class_name => 'Ivr::Audio', :foreign_key => 'ivr_nodes_id', :dependent => :destroy
    has_many :simple_children, :class_name => 'Ivr::Node', :foreign_key => 'parent_id'

    attr_accessor :main_node, :children, :dummy, :prompt_data, :confirm_data, :no_match_data, :related_accounts, :ok_node, :error_node

    validates_presence_of :name
    validates_length_of :name, :maximum => 50, :allow_blank => true
    validates_numericality_of :timeout, :maxtime
    validates :email_from, email: true, :if => :validates_email_fields
    validates_presence_of :email_from, :if => :validates_email_fields
    validates_presence_of :email_subject, :if => :validates_email_fields
    validates_presence_of :email_message, :if => :validates_email_fields

    protected

      after_initialize do
        # Audios
        self.prompt_data ||= { 'libs_audios_id' => String.new, 'text' => I18n.t('ivr.nodes.voicemail.audios.prompt.text'), 'tts_voice' => String.new }
        self.confirm_data ||= { 'libs_audios_id' => String.new, 'text' => I18n.t('ivr.nodes.voicemail.audios.confirm.text'), 'tts_voice' => String.new }
        self.no_match_data ||= { 'libs_audios_id' => String.new, 'text' => I18n.t('ivr.nodes.voicemail.audios.no_match.text'), 'tts_voice' => String.new }
        # Cuentas
        self.related_accounts ||= { 'a_0' => { 'libs_accounts_id' => String.new } }
      end

      after_find do
        # Audios
        unless self.audios.blank?
          self.prompt_data = self.audios.select{ |x| x.type == 'prompt' }[0]
          self.confirm_data = self.audios.select{ |x| x.type == 'confirm' }[0]
          self.no_match_data = self.audios.select{ |x| x.type == 'no_match' }[0]
        end
        # Cuentas
        self.related_accounts = Hash.new
        self.accounts.each{ |x| self.related_accounts["a_#{x.id}"] = { 'libs_accounts_id' => x.id } } unless self.accounts.blank?
        self.related_accounts['a_0'] = { 'libs_accounts_id' => String.new }
      end

      after_create do
        Ivr::Node.allocate_children self
      end

      after_save do
        # Audios
        # Borramos todas las locuciones asociadas hasta el momento y agregamos las nuevas
        self.audios.destroy_all
        %w(prompt confirm no_match).each do |x|
          new_a = Ivr::Audio.new({
            :libs_audios_id => eval("self.#{x}_data['libs_audios_id']"),
            :text => eval("self.#{x}_data['text']"),
            :tts_voice => eval("self.#{x}_data['tts_voice']"),
            :type => x,
            :ivr_nodes_id => self.id
          })
          # Si se ha seleccionado alguna locución, además de guardarla, la ponemos como activa en la tabla del nodo
          if new_a.valid?
            eval("self.#{x} = true") unless x == 'prompt'
            new_a.save
          else
            eval("self.#{x} = false") unless x == 'prompt'
          end
        end
        # Cuentas
        self.nodes_accounts.destroy_all
        unless self.related_accounts.blank?
          self.related_accounts.each do |k,v|
            unless v['libs_accounts_id'].blank?
              new_cn = Ivr::NodeAccount.new({
                :libs_accounts_id => v['libs_accounts_id'],
                :ivr_nodes_id => self.id
              })
              new_cn.save
            end
          end
        end
      end

      after_destroy do
        Ivr::Node.delete_children self
      end

    private

      # Si alguna de las cuentas es un email, sus campos asociados son obligatorios
      def validates_email_fields
        accounts_ids = self.related_accounts.map{ |k,v| v['libs_accounts_id'] }.delete_if{ |x| x.blank? }
        not Libs::Account.where(:id => accounts_ids).select{ |x| x.type == 'email'}.blank?
      end

      before_validation do
        # Un nodo de tipo buzón, como es lógico, siempre debe tener cuentas asociadas
        errors[:base].push(I18n.t('ivr.nodes.voicemail.error_messages.accounts')) if not self.related_accounts.blank? && self.related_accounts.values.delete_if{ |x| x['libs_accounts_id'].blank? }.blank?
      end
  end
end
