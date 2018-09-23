class CreateStates < ActiveRecord::Migration[5.2]
  def change
    create_table :states do |t|
      t.text :device, null: false
      t.text :os, null: false
      t.text :memory, null: false
      t.text :storage, null: false
      t.references :bug, foreign_key: true, index: true

      t.timestamps
    end
  end
end
