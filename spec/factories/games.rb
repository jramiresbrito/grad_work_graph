FactoryBot.define do
  factory :game do
    mode { %i[pvp pve both].sample }
    release_date { Time.zone.now }
    developer { Faker::Company.name }
    system_requirement
  end
end
