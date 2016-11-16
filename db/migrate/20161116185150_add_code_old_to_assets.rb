class AddCodeOldToAssets < ActiveRecord::Migration
  def change
    add_column :assets, :code_old, :string
  end
end
