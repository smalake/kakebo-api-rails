class CreatePatterns < ActiveRecord::Migration[7.0]
  def change
    create_table :patterns do |t|
      t.integer :user_id, null: false
      t.string :store_name, null: false
      t.integer :category, null: false
      t.timestamps
    end
  end
end
