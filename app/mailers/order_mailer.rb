class OrderMailer < ApplicationMailer
  def created(order)
    @order = order
    @user = set_user(@order)

    mail to: @user.email, subject: 'Pedido recebido'
  end

  def payment_received(order)
    @order = order
    @user = set_user(@order)

    mail to: @user.email, subject: 'Pagamento confirmado'
  end

  def payment_failed(order)
    @order = order
    @user = set_user(@order)

    mail to: @user.email, subject: 'Pagamento recusado'
  end

  private

  def set_user(order)
    User.find(@order.user_id)
  end
end
