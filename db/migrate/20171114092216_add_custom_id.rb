class AddCustomId < ActiveRecord::Migration[5.1]
  def change
    add_column :transactions, :transaction_no, :string
    add_column :transactions, :custom_id , :string

    add_index :transactions, :custom_id
  end
end
