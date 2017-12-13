class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
  	  t.string :email,              null: false, default: ""
  	  t.string :name
  	  t.string :logo_url
  	  t.string :access_token

  	  t.timestamps
  	end

  	add_index :users, :email,                unique: true
  	# add_index :users, :token
  end
end
