class IvrVoicemailNodes < ActiveRecord::Migration
  def self.up
    create_table 'ivr.nodes_accounts' do |t|
      t.integer :libs_accounts_id, :null => false
      t.references :ivr_nodes, :null => false
    end

    create_table 'ivr.voicemail_records' do |t|
      t.integer :users_id, :null => false
      t.references :ivr_nodes, :null => false
      t.datetime :datetime, :null => false
      t.string :token, :null => false
      t.string :ani, :limit => 30, :null => false
      t.string :call_id, :limit => 255, :null => false
      t.string :file, :null => false
    end
    add_index 'ivr.voicemail_records', :token, :unique => true

    execute "
      CREATE TABLE ivr.voicemail_nodes(
        email_from character varying(256),
        email_subject character varying(256),
        email_message text,
        send_now boolean NOT NULL DEFAULT true,
        maxtime integer NOT NULL DEFAULT 5,
        beep boolean NOT NULL DEFAULT true,
        bargein boolean NOT NULL DEFAULT true,
        timeout integer NOT NULL DEFAULT 10,
        confirm boolean NOT NULL DEFAULT true,
        no_match boolean NOT NULL DEFAULT true
      ) INHERITS(ivr.nodes);

      ALTER TABLE ivr.voicemail_nodes ADD PRIMARY KEY(id);

      -- Tigger de actualización del path de los nodos
      CREATE TRIGGER update_voicemail_node_path
        AFTER INSERT OR UPDATE
        ON ivr.voicemail_nodes
        FOR EACH ROW
        EXECUTE PROCEDURE ivr.update_nodes_path();"
  end

  def self.down
    drop_table 'ivr.voicemail_records'
    drop_table 'ivr.nodes_accounts'
    drop_table 'ivr.voicemail_nodes'
  end
end