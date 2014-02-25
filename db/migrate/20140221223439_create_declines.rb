class CreateDeclines < ActiveRecord::Migration
  def change
    create_table :declines do |t|
      t.string :asset_code
      t.string :account_code
      t.string :auxiliary_code
      t.string :department_code
      t.string :user_code
      t.text :description
      t.text :reason
      t.belongs_to :user, index: true

      t.timestamps
    end
  end
end
