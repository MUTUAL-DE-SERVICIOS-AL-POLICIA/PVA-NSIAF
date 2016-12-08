FactoryGirl.define do
  factory :auxiliary do
    sequence(:code)
    name "TERMOVENTILADOR"
    association :account
  end
end
