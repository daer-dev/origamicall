class IvrJumpNodes < ActiveRecord::Migration
  def self.up
    execute '
      CREATE TABLE ivr.jump_nodes(
        ivr_nodes_id integer
      ) INHERITS(ivr.nodes);

      ALTER TABLE ivr.jump_nodes ADD PRIMARY KEY(id);

      -- Tigger de actualización del path de los nodos
      CREATE TRIGGER update_jump_node_path
        AFTER INSERT OR UPDATE
        ON ivr.jump_nodes
        FOR EACH ROW
        EXECUTE PROCEDURE ivr.update_nodes_path();'
  end

  def self.down
    drop_table 'ivr.jump_nodes'
  end
end