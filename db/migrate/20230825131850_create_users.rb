class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :uid
      t.integer :group_id
      t.string :name
      t.integer :type

      t.timestamps
    end
  end
end
