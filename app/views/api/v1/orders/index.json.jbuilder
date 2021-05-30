json.orders do
  json.array! @loading_service.records do |order|
    json.partial! order
    json.order_items do
      json.array! order.order_items.each do |oi|
        json.partial! oi
      end
    end
  end
end

json.meta do
  json.partial! 'shared/pagination', pagination: @loading_service.pagination
end
