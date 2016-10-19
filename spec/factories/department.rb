FactoryGirl.define do
  factory :department do
    sequence(:code)
    name 'Unidad de Innovación, Investigación y Desarrollo'
    building
  end
end
