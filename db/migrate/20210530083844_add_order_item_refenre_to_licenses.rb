class AddOrderItemRefenreToLicenses < ActiveRecord::Migration[6.0]
  def change
    add_reference :licenses, :order_item, foreign_key: true
  end
end
