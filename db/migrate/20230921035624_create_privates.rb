class CreatePrivates < ActiveRecord::Migration[7.0]
  def change
    create_table :privates do |t|
      t.integer :amount, null: false
      t.integer :category
      t.string :date
      t.string :store_name
      t.string :memo
      t.integer :user_id, null: false

      t.timestamps
    end
  end
end
