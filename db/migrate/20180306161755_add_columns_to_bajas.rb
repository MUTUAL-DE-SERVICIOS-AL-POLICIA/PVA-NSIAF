class AddColumnsToBajas < ActiveRecord::Migration
  def change
    add_column :bajas, :motivo, :string
    add_column :bajas, :fecha_documento, :date
  end
end
