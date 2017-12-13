class CreateSettings < ActiveRecord::Migration[5.1]
  def change
	create_table :settings do |t|
		t.string :code, null: false
		t.string :name, null: false
		t.integer :warehouse_id
		t.string :warehouse_name
		t.timestamps
    end
  end
end
