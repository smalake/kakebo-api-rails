class CreateEvents < ActiveRecord::Migration[7.0]
  def change
    create_table :events do |t|
      t.integer :amount, null: false
      t.integer :category
      t.string :date
      t.string :store_name
      t.string :memo
      t.integer :group_id, null: false
      t.string :create_user
      t.string :update_user

      t.timestamps
    end
  end
end
