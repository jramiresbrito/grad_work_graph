class OrderItem < ApplicationRecord
  belongs_to :order, optional: true
  belongs_to :product
  has_many :licenses

  module Status
    WAITING_ORDER = 1
    PREPARING     = 2
    EN_ROUTE      = 3
    DELIVERED     = 4

    AVAILABLE_STATUS = [
      WAITING_ORDER, PREPARING, EN_ROUTE,
      DELIVERED
    ].freeze

    STATE_MACHINE = {
      WAITING_ORDER => [PREPARING],
      PREPARING => [EN_ROUTE],
      EN_ROUTE => [DELIVERED],
      DELIVERED => []
    }.freeze

    # List of related strings for each status
    def self.names_list
      {
        WAITING_ORDER => 'waiting_order',
        PREPARING => 'preparing',
        WAITING_PAYMENT => 'waiting_payment',
        EN_ROUTE => 'en_route',
        DELIVERED => 'delivered'
      }
    end

    # Human-readable I18n name for a given status
    def self.name(status)
      I18n.t("order_item.status.name.#{OrderItem::Status.names_list[status]}")
    end

    # Human-readable I18n message for a given status
    def self.message(status)
      I18n.t("order_item.status.message.#{OrderItem::Status.names_list[status]}")
    end
  end

  # validates :status, presence: true, inclusion: { in: OrderItem::Status::AVAILABLE_STATUS }
  validates :quantity, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :payed_price, presence: true, numericality: { greater_than: 0 }

  # before_validation :set_initial_status, on: :create

  # def set_initial_status
  #   self.status = OrderItem::Status::WAITING_ORDER
  # end

  def total
    payed_price * quantity
  end

  def ship!
    product.productable.ship!(self)
    # update!(status: OrderItem::Status::PREPARING)
  end

  # Human-readable I18n message for the current status of the batch
  def status_message
    OrderItem::Status.message(status)
  end

  # Human-readable I18n name for the current status of the batch
  def status_name
    OrderItem::Status.name(status)
  end

  # Validation method to check the status transitions
  def status_transitions
    if status != status_was && OrderItem::Status::STATE_MACHINE[status_was] &&
       !OrderItem::Status::STATE_MACHINE[status_was].include?(status)
      errors[:status] << I18n.t('activerecord.errors.messages.status_change',
                                status_was: OrderItem::Status.name(status_was),
                                new_status: OrderItem::Status.name(status))
    end
  end

  def set_previous_status
    self.previous_status = status_was
  end
end
