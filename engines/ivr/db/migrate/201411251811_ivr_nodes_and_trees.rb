class IvrNodesAndTrees < ActiveRecord::Migration
  def self.up
    execute 'CREATE SCHEMA ivr;'

    create_table 'ivr.nodes' do |t|
      t.string :name, :null => false, :limit => 50
      t.integer :parent_id
      t.boolean :active, :null => false, :default => true
      t.boolean :status
    end

    execute "
      ALTER TABLE ivr.nodes
        ADD COLUMN path ltree;

      -- Índice para agilizar operaciones sobre el path ltree
      CREATE INDEX path_gist ON ivr.nodes USING gist(path);

      -- Función que devuelve el path de un nodo
      CREATE OR REPLACE FUNCTION ivr.get_node_path(param_node_id integer)
        RETURNS ltree AS
        $BODY$
          SELECT CASE WHEN n.parent_id IS NULL
            THEN n.id::text::ltree
            ELSE ivr.get_node_path(n.parent_id) || n.id::text END
          FROM ivr.nodes AS n
          WHERE n.id = $1;
        $BODY$
      LANGUAGE 'sql' STABLE
      COST 100;
      ALTER FUNCTION ivr.get_node_path(integer) OWNER TO origami;
      GRANT EXECUTE ON FUNCTION ivr.get_node_path(integer) TO origami;

      -- Trigger para la actualización automática del path de los nodos en INSERTS y UPDATES
      CREATE OR REPLACE FUNCTION ivr.update_nodes_path()
        RETURNS trigger AS
        $BODY$
          BEGIN
            IF(TG_OP = 'UPDATE') THEN
              IF(COALESCE(OLD.parent_id,0) != COALESCE(NEW.parent_id,0) OR NEW.id != OLD.id) THEN
                UPDATE ivr.nodes SET path = ivr.get_node_path(id)
                  WHERE OLD.path  @> ivr.nodes.path;
              END IF;
              ELSIF(TG_OP = 'INSERT') THEN
                UPDATE ivr.nodes SET path = ivr.get_node_path(NEW.id) WHERE ivr.nodes.id = NEW.id;
            END IF;
            RETURN NEW;
          END
        $BODY$
      LANGUAGE 'plpgsql' VOLATILE
      COST 100;
      ALTER FUNCTION ivr.update_nodes_path() OWNER TO origami;

      CREATE TRIGGER update_node_path
        AFTER INSERT OR UPDATE
          ON ivr.nodes
          FOR EACH ROW
          EXECUTE PROCEDURE ivr.update_nodes_path();"

    create_table 'ivr.nodes_lists' do |t|
      t.integer :libs_lists_id, :null => false
      t.references :ivr_nodes, :null => false
    end

    execute '
      CREATE OR REPLACE VIEW ivr.nodes_view AS
        SELECT n.tableoid::regclass AS type, n.id, n.name, n.parent_id, n.active, n.path, n.status
        FROM ivr.nodes n;'

    create_table 'ivr.trees' do |t|
      t.string :name, :null => false, :limit => 50
      t.references :ivr_main_nodes
      t.integer :users_id, :null => false
    end

    create_table 'ivr.trees_services' do |t|
      t.references :ivr_trees, :null => false
      t.integer :services_id, :null => false
    end

    execute '
      ALTER TABLE ivr.trees_services
        ADD CONSTRAINT ivr_trees_id
        FOREIGN KEY(ivr_trees_id)
        REFERENCES ivr.trees(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE'
  end

  def self.down
    drop_table 'ivr.trees_services'
    drop_table 'ivr.trees'
    execute 'DROP VIEW ivr.nodes_view;'
    drop_table 'ivr.nodes'
    execute 'DROP FUNCTION ivr.update_nodes_path();'
    execute 'DROP FUNCTION ivr.get_node_path(integer);'
    execute 'DROP SCHEMA ivr;'
  end
end