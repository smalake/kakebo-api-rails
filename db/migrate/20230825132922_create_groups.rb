class CreateGroups < ActiveRecord::Migration[7.0]
  def change
    create_table :groups do |t|
      t.string :manage_uid

      t.timestamps
    end
  end
end
