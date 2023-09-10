class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :email, null: false
      t.string :password_digest, null: false
      t.integer :group_id, null: false
      t.string :name
      t.integer :register_type
      t.string :refresh_token

      t.timestamps
    end
    add_index :users, :email, unique: true
  end
end
