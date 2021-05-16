json.call(product, :id, :name, :description, :price, :image_url, :status, :featured)
json.productable product.productable_type.underscore
json.productable_id product.productable_id
json.categories product.categories
