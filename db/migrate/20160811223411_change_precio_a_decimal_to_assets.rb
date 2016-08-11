class ChangePrecioADecimalToAssets < ActiveRecord::Migration
  def up
    change_column :assets, :precio, :decimal, precision: 10, scale: 2, default: 0 , null: false
  end

  def down
    change_column :assets, :precio, :float
  end
end
