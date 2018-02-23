class CreateBajas < ActiveRecord::Migration
  def change
    create_table :bajas do |t|
      t.string :documento
      t.date :fecha
      t.text :observaciones
      t.belongs_to :user, index: true

      t.timestamps null: false
    end
  end
end
