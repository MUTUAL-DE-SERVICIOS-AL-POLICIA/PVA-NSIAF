FactoryGirl.define do
  factory :user do
    sequence(:code)
    sequence(:name, 'a') { |n| "Juan José Rocha #{n}" }
    title 'Profesional de Desarrollo'
    ci '1234567 LP'
    sequence(:email) { |n| "jrocha#{n}@agetic.gob.bo" }
    sequence(:username, 'a') { |n| "jrocha#{n}" }
    phone '212345'
    mobile '70612345'
    department
  end
end
