class CreateDevices < ActiveRecord::Migration[5.1]
  def change
    create_table :devices do |t|
      t.string :device_id
      t.string :device_name
      t.string :access_token
      t.integer :setting_id
      t.datetime :last_sync

      t.timestamps
    end

    add_index :devices, :setting_id
    add_index :devices, :access_token
    add_index :devices, :device_id
  end
end
