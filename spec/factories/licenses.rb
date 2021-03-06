FactoryBot.define do
  factory :license do
    key { Faker::Commerce.unique.promotion_code(digits: 16) }
    platform { :steam }
    status { License::Status::AVAILABLE }
    game
  end
end
