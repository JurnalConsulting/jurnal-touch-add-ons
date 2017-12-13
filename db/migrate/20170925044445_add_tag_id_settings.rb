class AddTagIdSettings < ActiveRecord::Migration[5.1]
  def change
  	add_column :settings, :tag_ids, :string
  end
end
