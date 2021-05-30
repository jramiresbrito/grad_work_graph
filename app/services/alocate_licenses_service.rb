class AlocateLicensesService
  def initialize(order_item)
    @order_item = order_item
  end

  def call
    licenses = @order_item.product.productable.licenses.where(status: License::Status::AVAILABLE).take(@order_item.quantity)
    License.transaction do
      update_licenses(licenses)
    end
    send_licenses
    # @order_item.update!(status: OrderItem::Status::DELIVERED)
  end

  private

  def update_licenses(licenses)
    licenses.each do |license|
      license.status = License::Status::IN_USE
      license.order_item = @order_item
      license.save!
    end
  end

  def send_licenses
    @order_item.licenses.each do |license|
      LicenseMailer.with(license: license).send_license.deliver_now
    end
  end
end
