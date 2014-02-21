class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string  :name
      t.string  :email
      t.string  :picture
      t.integer :legs,   default: 2
      t.integer :arms,   default: 2
      t.integer :state,  default: 0

      t.timestamps
    end
  end
end
