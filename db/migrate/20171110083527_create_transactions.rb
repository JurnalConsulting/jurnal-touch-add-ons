class CreateTransactions < ActiveRecord::Migration[5.1]
  def change
    create_table :transactions do |t|
      t.integer :device_id
      t.date :date
      t.integer :transaction_id
      t.decimal :amount, :precision => 50, :scale => 6

      t.timestamps
    end
    add_index :transactions, :device_id
    add_index :transactions, :transaction_id
    add_index :transactions, [:device_id, :transaction_id]
  end
end
