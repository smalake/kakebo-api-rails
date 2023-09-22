class CreatePrivates < ActiveRecord::Migration[7.0]
  def change
    create_table :privates do |t|
      t.integer :amount
      t.integer :category
      t.string :date
      t.string :store_name
      t.integer :user_id

      t.timestamps
    end
  end
end
