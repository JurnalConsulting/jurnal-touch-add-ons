class AddCompanyPackageToUser < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :company_package, :string
  end
end
