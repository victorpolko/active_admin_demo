class CreateHeads < ActiveRecord::Migration
  def change
    create_table :heads do |t|
      t.integer :iq, default: 120
      t.integer :user_id

      t.timestamps
    end
  end
end
