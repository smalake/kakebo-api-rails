class CreateEvents < ActiveRecord::Migration[7.0]
  def change
    create_table :events do |t|
      t.integer :amount
      t.integer :category
      t.string :date
      t.string :store_name
      t.integer :group_id
      t.string :create_user
      t.string :update_user

      t.timestamps
    end
  end
end
