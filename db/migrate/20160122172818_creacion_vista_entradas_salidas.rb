class CreacionVistaEntradasSalidas < ActiveRecord::Migration
  def up
    self.connection.execute %Q(
      CREATE OR REPLACE VIEW entradas_salidas AS

      SELECT es.id, subarticle_id, delivery_date as fecha, -total_delivered cantidad, request_id as modelo_id, 'salida' tipo, created_at
      FROM requests r INNER JOIN subarticle_requests es ON r.id=es.request_id
      WHERE r.invalidate = 0 AND es.invalidate = 0

      UNION

      SELECT id, subarticle_id, date as fecha, amount cantidad, note_entry_id as modelo_id, 'entrada' tipo, created_at
      FROM entry_subarticles
      WHERE invalidate = 0
      ORDER BY subarticle_id, fecha, cantidad DESC, created_at;
    )
  end

  def down
    self.connection.execute "DROP VIEW IF EXISTS entradas_salidas;"
  end
end
