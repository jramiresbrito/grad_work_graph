class License < ApplicationRecord
  include LikeSearchable
  include Paginatable

  belongs_to :game
  belongs_to :order_item, optional: true

  module Status
    AVAILABLE = 1
    IN_USE = 2
    INACTIVE = 3

    AVAILABLE_STATUS = [AVAILABLE, IN_USE, INACTIVE].freeze

    STATE_MACHINE = {
      AVAILABLE => [IN_USE, INACTIVE],
      IN_USE => [],
      INACTIVE => []
    }.freeze

    # List of related strings for each status
    def self.names_list
      {
        AVAILABLE => 'available',
        IN_USE => 'in_use',
        INACTIVE => 'inactive'
      }
    end

    # Human-readable I18n name for a given status
    def self.name(status)
      I18n.t("license.status.name.#{License::Status.names_list[status]}")
    end

    # Human-readable I18n message for a given status
    def self.message(status)
      I18n.t("license.status.message.#{License::Status.names_list[status]}")
    end
  end

  validates :status, presence: true, inclusion: { in: License::Status::AVAILABLE_STATUS }
  validates :key, :platform, presence: true
  validates :key, uniqueness: { case_sensitive: false, scope: :platform }
  validates :order_item, presence: true, if: -> { status == License::Status::IN_USE }

  enum platform: { steam: 1, epic: 2 }

  def set_initial_status
    self.status = License::Status::AVAILABLE
  end

  # Human-readable I18n message for the current status of the batch
  def status_message
    License::Status.message(status)
  end

  # Human-readable I18n name for the current status of the batch
  def status_name
    License::Status.name(status)
  end

  # Validation method to check the status transitions
  def status_transitions
    if status != status_was && License::Status::STATE_MACHINE[status_was] && !License::Status::STATE_MACHINE[status_was].include?(status)
      errors[:status] << I18n.t('activerecord.errors.messages.status_change', status_was: License::Status.name(status_was), new_status: License::Status.name(status))
    end
  end

  def set_previous_status
    self.previous_status = status_was
  end
end
