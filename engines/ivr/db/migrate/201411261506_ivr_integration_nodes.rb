class IvrIntegrationNodes < ActiveRecord::Migration
  def self.up
    execute "
    CREATE TABLE ivr.integration_nodes(
      content text,
      url character varying(255),
      type character varying(10) NOT NULL DEFAULT 'content'::character varying
    ) INHERITS(ivr.nodes);

    ALTER TABLE ivr.integration_nodes ADD PRIMARY KEY(id);

    -- Tigger de actualización del path de los nodos
    CREATE TRIGGER update_integration_node_path
      AFTER INSERT OR UPDATE
      ON ivr.integration_nodes
      FOR EACH ROW
      EXECUTE PROCEDURE ivr.update_nodes_path();"
  end

  def self.down
    drop_table 'ivr.integration_nodes'
  end
end