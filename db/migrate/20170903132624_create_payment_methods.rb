class CreatePaymentMethods < ActiveRecord::Migration[5.1]
  def change
    create_table :payment_methods do |t|

    	t.integer :payment_type_id
		t.string :payment_type_name
		t.integer :payment_account_id
		t.string :payment_account_name
		t.integer :payment_fee_account_id
		t.string :payment_fee_account_name
		t.integer :payment_fee_percentage
		t.integer :payment_fee_fixed
		t.integer :setting_id

      t.timestamps

    end
  end
end
