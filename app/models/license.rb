class License < ApplicationRecord
  include LikeSearchable
  include Paginatable

  belongs_to :game

  validates :key, :platform, :status, presence: true
  validates :key, uniqueness: { case_sensitive: false, scope: :platform }

  enum platform: { steam: 1, epic: 2 }
  enum status: { available: 1, in_use: 2, inactive: 3 }
end
