class IvrNodesWebView < ActiveRecord::Migration
  def self.up
    execute '
      CREATE OR REPLACE VIEW ivr.nodes_web_view AS
      SELECT n.tableoid::regclass AS type, n.id, n.name, n.parent_id, n.active, n.path, n.status, o.dtmf, lo.name as asr
      FROM ivr.nodes n
      LEFT JOIN ivr.options o ON n.id = o.ivr_nodes_id
      LEFT JOIN libs.options lo ON o.libs_options_id = lo.id;'

    execute '
      CREATE OR REPLACE RULE delete_ivr_nodes_web_view AS
        ON DELETE TO ivr.nodes_web_view
        DO INSTEAD
        DELETE FROM ivr.nodes
        WHERE nodes.id = old.id;'

    execute '
      CREATE OR REPLACE RULE insert_ivr_nodes_web_view AS
        ON INSERT TO ivr.nodes_web_view
        DO INSTEAD
        INSERT INTO ivr.nodes(name, parent_id, status)
        VALUES(new.name, new.parent_id, new.status);'

    execute '
      CREATE OR REPLACE RULE update_ivr_nodes_web_view AS
        ON UPDATE TO ivr.nodes_web_view
        DO INSTEAD
        UPDATE ivr.nodes
        SET name = new.name,
          parent_id = new.parent_id,
          active = new.active,
          status = new.status
        WHERE nodes.id = old.id;'
  end

  def self.down
    execute 'DROP VIEW ivr.nodes_web_view;'
  end
end