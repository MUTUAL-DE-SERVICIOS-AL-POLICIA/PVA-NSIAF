class AddColumnsToUser < ActiveRecord::Migration
  def change
    add_column :users, :username, :string
    add_column :users, :code, :integer
    add_column :users, :name, :string
    add_column :users, :post, :string
    add_column :users, :ci, :integer
    add_column :users, :phone, :integer
    add_column :users, :cellular, :integer
  end
end
