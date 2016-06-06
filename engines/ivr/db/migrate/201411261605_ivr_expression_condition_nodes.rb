class IvrExpressionConditionNodes < ActiveRecord::Migration
  def self.up
    execute '
      CREATE TABLE ivr.expression_condition_nodes(
        expression text
      ) INHERITS(ivr.nodes);

      ALTER TABLE ivr.expression_condition_nodes ADD PRIMARY KEY(id);

      -- Tigger de actualización del path de los nodos
      CREATE TRIGGER update_expression_condition_node_path
        AFTER INSERT OR UPDATE
        ON ivr.expression_condition_nodes
        FOR EACH ROW
        EXECUTE PROCEDURE ivr.update_nodes_path();'
  end

  def self.down
    drop_table 'ivr.expression_condition_nodes'
  end
end