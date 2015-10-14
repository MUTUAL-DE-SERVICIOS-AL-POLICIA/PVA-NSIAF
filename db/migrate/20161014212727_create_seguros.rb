class CreateSeguros < ActiveRecord::Migration
  def change
    create_table :seguros do |t|
      t.references :supplier
      t.references :user
      t.string :numero_contrato, limit: 255
      t.string :factura_numero,  limit: 255
      t.string :factura_autorizacion, limit: 255
      t.date :factura_fecha
      t.date :fecha_inicio_validez
      t.date :fecha_fin_validez
      t.boolean :baja_logica,  default: false
      t.timestamps null: false
    end
  end
end
