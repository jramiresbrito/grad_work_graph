class Order < ApplicationRecord
  include Paginatable

  attribute :credit_card_number
  belongs_to :user
  belongs_to :coupon, optional: true
  has_many :order_items

  module Status
    PROCESSING_ORDER = 1
    PROCESSING_ERROR = 2
    PAYMENT_ACCEPTED = 3
    PAYMENT_DENIED   = 4
    FINISHED         = 5

    AVAILABLE_STATUS = [
      PROCESSING_ORDER, PROCESSING_ERROR,
      PAYMENT_ACCEPTED, PAYMENT_DENIED, FINISHED
    ].freeze

    STATE_MACHINE = {
      PROCESSING_ORDER => [PROCESSING_ERROR, PAYMENT_ACCEPTED, PAYMENT_DENIED],
      PROCESSING_ERROR => [FINISHED],
      PAYMENT_ACCEPTED => [FINISHED],
      PAYMENT_DENIED => [FINISHED],
      FINISHED => []
    }.freeze

    # List of related strings for each status
    def self.names_list
      {
        PROCESSING_ORDER => 'processing_order',
        PROCESSING_ERROR => 'processing_error',
        PAYMENT_ACCEPTED => 'payment_accepted',
        PAYMENT_DENIED => 'payment_denied',
        FINISHED => 'finished'
      }
    end

    # Human-readable I18n name for a given status
    def self.name(status)
      I18n.t("order.status.name.#{Order::Status.names_list[status]}")
    end

    # Human-readable I18n message for a given status
    def self.message(status)
      I18n.t("order.status.message.#{Order::Status.names_list[status]}")
    end
  end

  validates :status, presence: true, inclusion: { in: Order::Status::AVAILABLE_STATUS }
  validates :subtotal, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :payment_type, presence: true

  with_options if: -> { credit_card? }, on: :create do
    validates :credit_card_number, presence: true
    validates :installments, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1 }
  end

  enum payment_type: { credit_card: 1, billet: 2 }

  validate :status_transitions

  before_validation :set_initial_status, on: :create
  before_validation :set_initial_subtotal, on: :create
  after_create :send_order_received_email
  around_update :ship_order, if: -> { status_changed?(to: Order::Status::PAYMENT_ACCEPTED) }
  around_update :send_failure_email, if: -> { status_changed?(to: Order::Status::PROCESSING_ERROR) }

  # Human-readable I18n message for the current status of the batch
  def status_message
    Order::Status.message(status)
  end

  # Human-readable I18n name for the current status of the batch
  def status_name
    Order::Status.name(status)
  end

  # Validation method to check the status transitions
  def status_transitions
    if status != status_was && Order::Status::STATE_MACHINE[status_was] && !Order::Status::STATE_MACHINE[status_was].include?(status)
      errors[:status] << I18n.t('activerecord.errors.messages.status_change', status_was: Order::Status.name(status_was), new_status: Order::Status.name(status))
    end
  end

  def set_previous_status
    self.previous_status = status_was
  end

  def update_subtotal!
    subtotal = 0

    order_items.each do |oi|
      subtotal += oi.total
    end

    update_attributes!(subtotal: subtotal)
  end

  private

  def ship_order
    OrderMailer.payment_received(self).deliver_now
    yield
    order_items.each { |order_item| order_item.ship! }
  end

  def send_order_received_email
    OrderMailer.created(self).deliver_now
  end

  # Sets the initial state for Orders
  def set_initial_status
    self.status = Order::Status::PROCESSING_ORDER
  end

  def set_initial_subtotal
    self.subtotal = 0
  end

  def send_failure_email
    OrderMailer.payment_failed(self).deliver_now
  end
end
