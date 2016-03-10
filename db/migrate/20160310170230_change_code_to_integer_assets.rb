class ChangeCodeToIntegerAssets < ActiveRecord::Migration
  def up
    change_column :assets, :code, :integer
  end

  def down
    change_column :assets, :code, :string, limit: 50
  end
end
