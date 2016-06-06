class IvrAudioNodes < ActiveRecord::Migration
  def self.up
    create_table 'ivr.audios' do |t|
      t.text :text
      t.string :tts_voice, :limit => 20
      t.string :language, :limit => 5, :null => false, :default => 'es-ES'
      t.integer :order, :null => false, :default => 0
      t.string :type, :limit => 20
      t.integer :libs_audios_id
      t.references :ivr_nodes, :null => false
    end

    execute '
      CREATE TABLE ivr.audio_nodes() INHERITS(ivr.nodes);

      ALTER TABLE ivr.audio_nodes ADD PRIMARY KEY(id);

      -- Tigger de actualización del path de los nodos
      CREATE TRIGGER update_audio_node_path
        AFTER INSERT OR UPDATE
        ON ivr.audio_nodes
        FOR EACH ROW
        EXECUTE PROCEDURE ivr.update_nodes_path();'
  end

  def self.down
    drop_table 'ivr.audios'
    drop_table 'ivr.audio_nodes'
  end
end
