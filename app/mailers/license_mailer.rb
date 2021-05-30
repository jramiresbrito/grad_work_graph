class LicenseMailer < ApplicationMailer
  def send_license
    @order = params[:license].order_item.order
    @license = params[:license]
    @user = @license.order_item.order.user
    mail(to: @user.email)
  end
end
