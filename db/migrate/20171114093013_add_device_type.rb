class AddDeviceType < ActiveRecord::Migration[5.1]
  def change
    add_column :devices, :device_type, :string
  end
end
