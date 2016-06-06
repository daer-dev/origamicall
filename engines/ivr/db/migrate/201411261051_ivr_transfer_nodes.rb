class IvrTransferNodes < ActiveRecord::Migration
  def self.up
    execute "
      CREATE TABLE ivr.transfer_nodes(
        caller_id integer,
        strategy character varying(20) NOT NULL DEFAULT 'linear',
        maxtime integer DEFAULT 60
      ) INHERITS(ivr.nodes);

      ALTER TABLE ivr.transfer_nodes ADD PRIMARY KEY(id);

      -- Tigger de actualización del path de los nodos
      CREATE TRIGGER update_transfer_node_path
        AFTER INSERT OR UPDATE
        ON ivr.transfer_nodes
        FOR EACH ROW
        EXECUTE PROCEDURE ivr.update_nodes_path();"

    create_table 'ivr.destinations' do |t|
      t.string :type, :null => false, :limit => 20
      t.integer :order, :null => false, :default => 0
      t.integer :percent
      t.integer :timeout, :null => false, :default => 20
      t.integer :phone_number
      t.integer :libs_destinations_id
      t.references :ivr_variables
      t.references :ivr_nodes, :null => false
    end

    execute '
      ALTER TABLE ivr.destinations
        ADD CONSTRAINT ivr_variables_id
        FOREIGN KEY(ivr_variables_id)
        REFERENCES ivr.variables(id)
        ON DELETE CASCADE'
  end

  def self.down
    drop_table 'ivr.destinations'
    drop_table 'ivr.transfer_nodes'
  end
end
