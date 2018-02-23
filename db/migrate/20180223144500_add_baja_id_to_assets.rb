class AddBajaIdToAssets < ActiveRecord::Migration
  def change
    add_reference :assets, :baja, index: true, foreign_key: true
  end
end
