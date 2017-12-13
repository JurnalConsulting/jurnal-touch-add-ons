class AddPaymentToTransaction < ActiveRecord::Migration[5.1]
  def change
    add_column :transactions, :payment_id, :integer
    add_column :transactions, :payment_method_id, :integer
  end
end
