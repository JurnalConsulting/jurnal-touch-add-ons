class AddColumnToDevice < ActiveRecord::Migration[5.1]
  def change
    add_column :devices, :device_app_version, :string
    add_column :devices, :device_os_version, :string
    add_column :devices, :longitude, :string
    add_column :devices, :latitude, :string
  end
end
