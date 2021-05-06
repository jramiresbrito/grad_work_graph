class Category < ApplicationRecord
  include LikeSearchable
  include Paginatable

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
