class CreateProcedimientos < ActiveRecord::Migration
  def change
    create_table :procedimientos do |t|
      t.string :clase
      t.string :metodo
      t.string :parametros
      t.string :descripcion
      t.boolean :baja_logica, default: false

      t.timestamps null: false
    end
  end
end
