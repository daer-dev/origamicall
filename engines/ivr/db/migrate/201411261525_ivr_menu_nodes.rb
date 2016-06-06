class IvrMenuNodes < ActiveRecord::Migration
  def self.up
    create_table 'ivr.options' do |t|
      t.references :ivr_nodes, :null => false
      t.references :ivr_menu_nodes, :null => false
      t.string :dtmf, :limit => 30
      t.boolean :default, :null => false, :default => false
      t.integer :libs_options_id
    end

    create_table 'ivr.nodes_grammars' do |t|
      t.integer :libs_grammars_id, :null => false
      t.references :ivr_nodes, :null => false
    end

    execute "
      CREATE TABLE ivr.menu_nodes(
        asr boolean NOT NULL DEFAULT false,
        bargein boolean NOT NULL DEFAULT true,
        maxlen integer NOT NULL DEFAULT 30,
        language character varying(5) NOT NULL DEFAULT 'es-ES'::character varying,
        timeout integer NOT NULL DEFAULT 15,
        times integer NOT NULL DEFAULT 1,
        ivr_variables_id integer
      ) INHERITS(ivr.nodes);

      ALTER TABLE ivr.menu_nodes ADD PRIMARY KEY(id);

      -- Tigger de actualizacion del path de los nodos
      CREATE TRIGGER update_menu_node_path
        AFTER INSERT OR UPDATE
        ON ivr.menu_nodes
        FOR EACH ROW
        EXECUTE PROCEDURE ivr.update_nodes_path();"
  end

  def self.down
    drop_table 'ivr.options'
    drop_table 'ivr.nodes_grammars'
    drop_table 'ivr.menu_nodes'
  end
end