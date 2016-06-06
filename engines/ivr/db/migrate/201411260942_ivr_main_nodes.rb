class IvrMainNodes < ActiveRecord::Migration
  def self.up
    execute '
      CREATE TABLE ivr.main_nodes(
        lists_type character varying(20)
      ) INHERITS(ivr.nodes);

      ALTER TABLE ivr.main_nodes ADD PRIMARY KEY(id);

      -- Tigger de actualización del path de los nodos
      CREATE TRIGGER update_main_node_path
        AFTER INSERT OR UPDATE
        ON ivr.main_nodes
        FOR EACH ROW
        EXECUTE PROCEDURE ivr.update_nodes_path();'

    create_table 'ivr.nodes_tables' do |t|
      t.integer :libs_tables_id, :null => false
      t.references :ivr_nodes, :null => false
    end

    create_table 'ivr.variables' do |t|
      t.string :name, :limit => 50, :null => false
      t.text :value
      t.string :type, :limit => 20, :null => false
      t.references :ivr_nodes, :null => false
    end
  end

  def self.down
    drop_table 'ivr.variables'
    drop_table 'ivr.nodes_tables'
    drop_table 'ivr.main_nodes'
  end
end