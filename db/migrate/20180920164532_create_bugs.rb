class CreateBugs < ActiveRecord::Migration[5.2]
  def change
    create_table :bugs do |t|
      t.text :application_token, null: false
      t.bigint :number, null: false
      t.text :priority, null: false
      t.text :status, null: false

      t.timestamps
    end

    add_index :bugs, [:application_token, :number], unique: true
  end
end
