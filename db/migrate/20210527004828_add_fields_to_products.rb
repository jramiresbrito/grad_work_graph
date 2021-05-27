class AddFieldsToProducts < ActiveRecord::Migration[6.0]
  def change
    add_column :products, :long_description, :text
  end
end
