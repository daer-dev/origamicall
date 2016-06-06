class IvrScheduleConditionNodes < ActiveRecord::Migration
  def self.up
    execute '
      CREATE TABLE ivr.schedule_condition_nodes(
        libs_schedules_id integer
      ) INHERITS(ivr.nodes);

      ALTER TABLE ivr.schedule_condition_nodes ADD PRIMARY KEY(id);

      -- Tigger de actualización del path de los nodos
      CREATE TRIGGER update_schedule_condition_node_path
        AFTER INSERT OR UPDATE
        ON ivr.schedule_condition_nodes
        FOR EACH ROW
        EXECUTE PROCEDURE ivr.update_nodes_path();'
  end

  def self.down
    drop_table 'ivr.schedule_condition_nodes'
  end
end