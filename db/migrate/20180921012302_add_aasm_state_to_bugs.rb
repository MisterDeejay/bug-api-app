class AddAasmStateToBugs < ActiveRecord::Migration[5.2]
  def change
    add_column :bugs, :aasm_state, :string
  end
end
