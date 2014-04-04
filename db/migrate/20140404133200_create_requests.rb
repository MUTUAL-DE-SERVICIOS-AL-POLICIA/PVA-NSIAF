class CreateRequests < ActiveRecord::Migration
  def change
    create_table :requests do |t|
      t.integer :admin_id
      t.integer :user_id
      t.integer :material_id
      t.integer :amount

      t.timestamps
    end
  end
end
