class RenamePaymentMethodUser < ActiveRecord::Migration[5.1]
  def change
    add_column :settings, :token, :string
    add_column :payment_methods, :token, :string
  end
end
