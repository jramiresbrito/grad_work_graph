module Api::V1
  class OrdersController < ApiController
    before_action :set_order, only: :show

    def index
      @loading_service = ModelLoadingService.new(Order.all, searchable_params)
      @loading_service.call
    end

    def create
      @order = Order.new
      save_order!
      if @order.credit_card_number == "0"
        simulate_failed_payment
      else
        @order_items = save_order_items!
        @order.update!(order_items: @order_items)
        simulate_success_payment
      end
    end

    private

    def set_order
      @order = Order.find(params[:id])
    end

    def searchable_params
      params.permit({ order: {} }, :page, :length)
    end

    def order_params
      return {} unless params.key?(:order)

      params.require(:order).permit(:credit_card_number,
                                    :payment_type,
                                    :installments, :coupon_id, order_items: [])
    end

    def order_item_params
      params.require(:order_items).permit(:product_id, :quantity)
    end

    def save_order!
      @order.attributes = order_params.except(:order_items)
      @order.user = @current_user
      @order.save!
    rescue StandardError
      render_error(fields: @order.errors.messages)
    end

    def save_order_items!
      order_items = []

      params[:order][:order_items].each do |item|
        product = Product.find(item[:product_id])
        product_price = product.price
        order_item = OrderItem.new(quantity: item[:quantity],
                                   product: product,
                                   payed_price: product_price,
                                   order: @order)
        order_item.save!
        order_items << order_item
      end

      order_items
    rescue StandardError
      order_items.each do |order_item|
        render_error(fields: order_item.errors.messages)
      end
    end

    # Method to simulate the failure hook from the payment provider
    def simulate_failed_payment
      @order.update(status: Order::Status::PROCESSING_ERROR)
    end

    # Method to simulate the success hook from the payment provider
    def simulate_success_payment
      @order.update(status: Order::Status::PAYMENT_ACCEPTED)
    end
  end
end
