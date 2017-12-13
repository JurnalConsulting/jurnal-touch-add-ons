class ChangeUsersTable < ActiveRecord::Migration[5.1]
  def change
  	add_column :users, :phone, :string
  	add_column :users, :fax, :string
  	add_column :users, :address, :string
  	add_column :users, :company_website, :string
  	add_column :users, :default_invoice_message, :string
  end
end