class CreateAlerta < ActiveRecord::Migration
  def change
    create_table :alerta do |t|
      t.references :procedimiento
      t.string :mensaje
      t.string :tipo
      t.string :clase
      t.boolean :parpadeo, default: false
      t.string :controlador
      t.string :accion
      t.boolean :baja_logica, default: false

      t.timestamps null: false
    end
  end
end
