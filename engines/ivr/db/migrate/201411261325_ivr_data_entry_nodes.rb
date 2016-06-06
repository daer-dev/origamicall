class IvrDataEntryNodes < ActiveRecord::Migration
  def self.up
    execute "
      CREATE TABLE ivr.data_entry_nodes(
        asr boolean NOT NULL DEFAULT false,
        bargein boolean NOT NULL DEFAULT true,
        timeout integer NOT NULL DEFAULT 15,
        times integer NOT NULL DEFAULT 1,
        beep boolean NOT NULL DEFAULT false,
        field_type character varying(30),
        ivr_variables_id integer NOT NULL
      ) INHERITS(ivr.nodes);

      ALTER TABLE ivr.data_entry_nodes ADD PRIMARY KEY(id);

      -- Tigger de actualización del path de los nodos
      CREATE TRIGGER update_data_entry_node_path
        AFTER INSERT OR UPDATE
        ON ivr.data_entry_nodes
        FOR EACH ROW
        EXECUTE PROCEDURE ivr.update_nodes_path();"
  end

  def self.down
    drop_table 'ivr.data_entry_nodes'
  end
end