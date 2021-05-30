FactoryBot.define do
  factory :order do
    status { 1 }
    subtotal { "9.99" }
    payment_type { 1 }
    user { nil }
    coupon { nil }
  end
end
