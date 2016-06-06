class IvrSourceConditionNodes < ActiveRecord::Migration
  def self.up
    execute '
      CREATE TABLE ivr.source_condition_nodes() INHERITS(ivr.nodes);

      ALTER TABLE ivr.source_condition_nodes ADD PRIMARY KEY(id);

      -- Tigger de actualización del path de los nodos
      CREATE TRIGGER update_source_condition_nodes_path
        AFTER INSERT OR UPDATE
        ON ivr.source_condition_nodes
        FOR EACH ROW
        EXECUTE PROCEDURE ivr.update_nodes_path();'

    create_table 'ivr.sources' do |t|
      t.integer :phone_number
      t.string :mode, :null => false
      t.references :ivr_source_condition_nodes, :null => false
    end

    execute '
      ALTER TABLE ivr.sources
        ADD CONSTRAINT ivr_source_condition_nodes_id
        FOREIGN KEY(ivr_source_condition_nodes_id)
        REFERENCES ivr.source_condition_nodes(id)
        ON DELETE CASCADE'
  end

  def self.down
    drop_table 'ivr.sources'
    drop_table 'ivr.source_condition_nodes'
  end
end